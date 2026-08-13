import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/common.dart';

/// {@template sqlite_delegate}
/// Delegate for the SQLite database.
/// {@endtemplate}
class SQLiteDelegate extends RaindropDelegate with _DatabaseDelegate {
  /// {@macro sqlite_delegate}
  ///
  /// [supportsUpdateDeleteLimit] says whether [database] parses a `LIMIT` hung
  /// directly off an `UPDATE` or a `DELETE`, which decides how a capped write
  /// is rendered. Left unset, the library is asked — see [probeForLimitSupport]
  /// for what that costs and when it can answer wrong.
  SQLiteDelegate(CommonDatabase database, {bool? supportsUpdateDeleteLimit})
      : _database = database,
        super(
          dialect: SQLiteDialect(
            supportsUpdateDeleteLimit: supportsUpdateDeleteLimit ??
                probeForLimitSupport(database),
          ),
        );

  /// Whether [database] was compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`.
  ///
  /// Asks the library itself rather than guessing from the platform, because
  /// the answer is a property of the build and not of the OS: the binaries
  /// `package:sqlite3` ships say no, macOS's system library says yes.
  ///
  /// Read-only and touches no schema — one scalar query against a compile-time
  /// flag. Any failure answers false, including the build that omitted the
  /// diagnostic function itself: that direction renders the subquery, which is
  /// slower but parses everywhere, whereas a wrong yes is a syntax error the
  /// caller only meets when the statement runs.
  static bool probeForLimitSupport(CommonDatabase database) {
    try {
      final result = database.select(
        "SELECT sqlite_compileoption_used('SQLITE_ENABLE_UPDATE_DELETE_LIMIT')"
        ' AS used',
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
      stmt.close();
    }
  }
}
