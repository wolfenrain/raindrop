import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:raindrop/src/migration/migration.dart';
import 'package:raindrop/src/raindrop.dart';
import 'package:raindrop/src/sql_dialect.dart';

/// Executes pending [migrations] against [db].
///
/// Migrations are tracked in a `_raindrop_migrations` table. Each pending
/// migration is executed in its own transaction. If a migration fails,
/// previously applied migrations remain intact.
///
/// Throws a [MigrationChecksumMismatch] if an already-applied migration's
/// SQL content has changed (schema drift detection).
///
/// Example:
/// ```dart
/// await migrate(db, [
///   Migration('0000_initial', 'CREATE TABLE ...'),
/// ]);
/// ```
Future<void> migrate(Raindrop db, List<Migration> migrations) async {
  await db.ensureOpen();
  await _Migrator(db).run(migrations);
}

/// Thrown when a previously applied migration's checksum doesn't match
/// the current source, indicating schema drift.
class MigrationChecksumMismatch implements Exception {
  /// Creates a new [MigrationChecksumMismatch].
  const MigrationChecksumMismatch(this.tag, this.expected, this.actual);

  /// The migration tag that has a checksum mismatch.
  final String tag;

  /// The checksum that was recorded when the migration was applied.
  final String expected;

  /// The current checksum of the migration source.
  final String actual;

  @override
  String toString() =>
      'MigrationChecksumMismatch: Migration "$tag" has been modified after '
      'being applied. Expected checksum "$expected" but got "$actual".';
}

class _Migrator {
  _Migrator(this._db) : _dialect = _db.delegate.dialect;

  final Raindrop _db;

  final SqlDialect _dialect;

  Future<void> run(List<Migration> allMigrations) async {
    await _dialect.ensureMigrationStorage(_db.execute);
    final applied = await _dialect.loadAppliedMigrations(_db.execute);

    for (final record in applied) {
      final matching = allMigrations.where((m) => m.tag == record.tag);
      if (matching.isEmpty) continue;

      final checksum = _calculateChecksum(matching.first.sql);
      if (checksum != record.checksum) {
        throw MigrationChecksumMismatch(record.tag, record.checksum, checksum);
      }
    }

    final appliedTags = applied.map((r) => r.tag).toSet();
    final pending =
        allMigrations.where((m) => !appliedTags.contains(m.tag)).toList();

    for (final migration in pending) {
      final checksum = _calculateChecksum(migration.sql);

      await _db.transaction((tx) async {
        final statements = _splitStatements(migration.sql);
        for (final statement in statements) {
          await tx.execute(statement);
        }

        await _dialect.recordMigration(
          tx.execute,
          tag: migration.tag,
          checksum: checksum,
        );
      });
    }
  }

  List<String> _splitStatements(String sql) =>
      sql.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  String _calculateChecksum(String v) =>
      sha256.convert(utf8.encode(v)).toString().substring(0, 16);
}
