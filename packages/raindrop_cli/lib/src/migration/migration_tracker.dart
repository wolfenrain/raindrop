import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Represents a recorded migration.
class MigrationRecord {
  const MigrationRecord({
    required this.id,
    required this.name,
    required this.appliedAt,
    required this.checksum,
  });

  final int id;
  final String name;
  final DateTime appliedAt;
  final String checksum;

  factory MigrationRecord.fromMap(Map<String, dynamic> map) {
    return MigrationRecord(
      id: map['id'] as int,
      name: map['name'] as String,
      appliedAt: DateTime.parse(map['applied_at'] as String),
      checksum: map['checksum'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'applied_at': appliedAt.toIso8601String(),
      'checksum': checksum,
    };
  }
}

/// Tracks applied migrations.
///
/// In a full implementation, this would interact with the database.
/// For now, it uses a local JSON file to track migrations.
class MigrationTracker {
  MigrationTracker(this.trackingPath);

  final String trackingPath;

  /// Loads all recorded migrations.
  Future<List<MigrationRecord>> loadMigrations() async {
    final file = File(trackingPath);
    if (!file.existsSync()) {
      return [];
    }

    final content = await file.readAsString();
    final data = jsonDecode(content) as List<dynamic>;
    return data
        .map((e) => MigrationRecord.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Records a new migration.
  Future<void> recordMigration(String name, String sqlContent) async {
    final migrations = await loadMigrations();

    final newId = migrations.isEmpty ? 1 : migrations.last.id + 1;
    final checksum = _calculateChecksum(sqlContent);

    final record = MigrationRecord(
      id: newId,
      name: name,
      appliedAt: DateTime.now(),
      checksum: checksum,
    );

    migrations.add(record);

    final file = File(trackingPath);
    final dir = Directory(p.dirname(trackingPath));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        migrations.map((m) => m.toMap()).toList(),
      ),
    );
  }

  /// Checks if a migration has been applied.
  Future<bool> isMigrationApplied(String name) async {
    final migrations = await loadMigrations();
    return migrations.any((m) => m.name == name);
  }

  /// Gets pending migrations from a directory.
  Future<List<File>> getPendingMigrations(String migrationsDir) async {
    final dir = Directory(migrationsDir);
    if (!dir.existsSync()) {
      return [];
    }

    final appliedMigrations = await loadMigrations();
    final appliedNames = appliedMigrations.map((m) => m.name).toSet();

    final allMigrations = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    return allMigrations
        .where((f) => !appliedNames.contains(p.basename(f.path)))
        .toList();
  }

  String _calculateChecksum(String content) {
    final bytes = utf8.encode(content);
    return sha256.convert(bytes).toString().substring(0, 16);
  }
}

/// SQL for creating the migrations tracking table.
const createMigrationsTableSql = '''
CREATE TABLE IF NOT EXISTS "_raindrop_migrations" (
  "id" INTEGER PRIMARY KEY,
  "name" TEXT NOT NULL UNIQUE,
  "applied_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "checksum" TEXT NOT NULL
);
''';
