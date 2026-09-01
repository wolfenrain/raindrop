import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_sqlite/src/sqlite_ddl.dart';
import 'package:sqlite3/common.dart';

/// {@template sqlite_delegate}
/// Delegate for the SQLite database.
/// {@endtemplate}
class SQLiteDelegate extends RaindropDelegate with _DatabaseDelegate {
  /// {@macro sqlite_delegate}

  SQLiteDelegate(CommonDatabase database, {bool enforceForeignKeys = true})
      : _database = checkSupportedVersion(database),
        super(
          dialect: SQLiteDialect(
            supportsUpdateDeleteLimit: probeForLimitSupport(database),
          ),
        ) {
    if (enforceForeignKeys) {
      _database.execute('PRAGMA foreign_keys = ON');
    }
  }

  @override
  final migrationStorage = DdlMigrationStorage(const SQLiteDdlGenerator());

  /// The oldest SQLite version this driver supports.
  ///
  /// 3.44.0 is where `RETURNING` started to apply column affinity, which row
  /// decoding relies on.
  static const minimumVersion = '3.44.0';

  /// Returns [database] when its library is [minimumVersion] or newer, and
  /// throws an [UnsupportedError] naming both versions otherwise.
  static CommonDatabase checkSupportedVersion(CommonDatabase database) {
    final version = database
        .select('SELECT sqlite_version() AS version')
        .first['version']! as String;
    if (!isSupportedVersion(version)) {
      throw UnsupportedError(
        'raindrop_sqlite needs SQLite $minimumVersion or newer, but the '
        'loaded library is $version.',
      );
    }
    return database;
  }

  /// Whether [version] (`"3.44.0"`) is [minimumVersion] or newer, compared
  /// numerically per segment.
  static bool isSupportedVersion(String version) {
    final parts = [
      for (final part in version.split('.')) int.tryParse(part) ?? 0,
      0,
      0,
    ];
    const minimum = [3, 44, 0];
    for (var i = 0; i < minimum.length; i++) {
      if (parts[i] != minimum[i]) return parts[i] > minimum[i];
    }
    return true;
  }

  /// Whether [database] was compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`,
  /// which decides how a capped write renders, see `LimitedWriteClause`.
  static bool probeForLimitSupport(CommonDatabase database) =>
      _hasCompileOption(database, 'SQLITE_ENABLE_UPDATE_DELETE_LIMIT');

  /// Whether [database] was compiled with [name]. Any failure answers false,
  /// including the build that omitted the diagnostic function itself.
  static bool _hasCompileOption(CommonDatabase database, String name) {
    try {
      final result = database.select(
        'SELECT sqlite_compileoption_used(?) AS used',
        [name],
      );
      return result.first['used'] == 1;
    } on Object {
      return false;
    }
  }

  @override
  final CommonDatabase _database;

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final tx = _TransactionDelegate(_database, this.dialect);
    _database.execute('BEGIN', []);

    try {
      final result = await transaction(tx);
      _database.execute('COMMIT', []);
      return result;
    } catch (_) {
      _database.execute('ROLLBACK', []);
      rethrow;
    }
  }
}

class _TransactionDelegate extends TransactionDelegate with _DatabaseDelegate {
  _TransactionDelegate(this._database, super.dialect, [super.depth]);

  @override
  final CommonDatabase _database;

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final savePoint = 'sp_$depth';
    final tx = _TransactionDelegate(_database, this.dialect, depth + 1);
    _database.execute('SAVEPOINT $savePoint', []);

    try {
      final result = await transaction(tx);
      _database.execute('RELEASE SAVEPOINT $savePoint', []);
      return result;
    } catch (_) {
      _database.execute('ROLLBACK TO $savePoint', []);
      rethrow;
    }
  }

  @override
  Never rollback() => throw const TransactionRollback();
}

mixin _DatabaseDelegate on Delegate {
  CommonDatabase get _database;

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) {
    final stmt = _database.prepare(query);
    try {
      final modifiesDatabase = !stmt.isReadOnly;
      final resultSet = stmt.select(values);
      final lastRowId = _database.lastInsertRowId;

      return Future.value(
        DatabaseResult(
          columns: resultSet.columnNames,
          rows: [...resultSet.map((row) => row.values)],
          rowsAffected: modifiesDatabase ? _database.updatedRows : 0,
          lastInsertedRowId:
              modifiesDatabase && lastRowId != 0 ? lastRowId : null,
        ),
      );
    } finally {
      stmt.close();
    }
  }
}
