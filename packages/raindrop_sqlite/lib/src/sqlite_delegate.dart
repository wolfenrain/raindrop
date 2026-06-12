import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';

/// {@template sqlite_delegate}
/// Delegate for the SQLite database.
/// {@endtemplate}
class SQLiteDelegate extends RaindropDelegate with _DatabaseDelegate {
  SQLiteDelegate._(this._database) : super(dialect: const SQLiteDialect());

  /// {@macro sqlite_delegate}
  ///
  /// Open the database at the [fileName].
  SQLiteDelegate.open(String fileName) : this._(sqlite3.open(fileName));

  /// {@macro sqlite_delegate}
  ///
  /// Open the database in memory
  SQLiteDelegate.memory({String? vfs}) : this._(sqlite3.openInMemory(vfs: vfs));

  @override
  final Database _database;

  @override
  Future<void> onOpen() async {}

  @override
  Future<void> onClose() async => _database.dispose();

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final tx = _TransactionDelegate(_database, dialect);
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
  final Database _database;

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final savePoint = 'sp_$depth';
    final tx = _TransactionDelegate(_database, dialect, depth + 1);
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
  Database get _database;

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
      stmt.dispose();
    }
  }
}
