import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/common.dart';

/// {@template sqlite_delegate}
/// Delegate for the SQLite database.
/// {@endtemplate}
class SQLiteDelegate extends RaindropDelegate with _DatabaseDelegate {
  /// {@macro sqlite_delegate}
  SQLiteDelegate(this._database) : super(dialect: const SQLiteDialect());

  @override
  final CommonDatabase _database;

  /// Serializes every top-level [execute]/[transaction] call against this
  /// connection.
  ///
  /// `sqlite3` only allows one transaction open at a time per connection —
  /// a second `BEGIN` before the first `COMMIT`/`ROLLBACK` throws "cannot
  /// start a transaction within a transaction" rather than queuing. Without
  /// this chain, two concurrent callers sharing one [SQLiteDelegate] (e.g.
  /// concurrent HTTP requests reusing the read connection) race on that
  /// `BEGIN` and one of them fails. Chaining onto a single `Future` forces
  /// each call to wait for the previous one's `COMMIT`/`ROLLBACK` before
  /// starting its own.
  Future<void> _chain = Future.value();

  Future<T> _serialized<T>(Future<T> Function() body) {
    final ticket = _chain.then((_) => body());
    _chain = ticket.then((_) {}, onError: (_) {});
    return ticket;
  }

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) {
    return _serialized(() => super.execute(query, values));
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) {
    return _serialized(() => _runTransaction(transaction));
  }

  Future<T> _runTransaction<T>(
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
  final CommonDatabase _database;

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
      stmt.dispose();
    }
  }
}
