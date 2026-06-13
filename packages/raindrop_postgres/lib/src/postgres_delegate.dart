import 'package:postgres/postgres.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

/// {@template postgres_delegate}
/// Delegate for the Postgres database.
/// {@endtemplate}
class PostgresDelegate extends RaindropDelegate with _SessionDelegate {
  /// {@macro postgres_delegate}
  ///
  /// Provide an already-open [SessionExecutor], such as a [Connection] or a
  /// [Pool].
  PostgresDelegate(this._executor) : super(dialect: const PostgresDialect());

  final SessionExecutor _executor;

  @override
  Session get _session => _executor as Session;

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) {
    return _executor.runTx((session) {
      return transaction(
        _TransactionDelegate(session, dialect),
      );
    });
  }
}

class _TransactionDelegate extends TransactionDelegate
    with _SessionDelegate<TxSession> {
  _TransactionDelegate(this._session, super.dialect, [super.depth]);

  @override
  final TxSession _session;

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final savePoint = 'sp_$depth';
    final tx = _TransactionDelegate(_session, dialect, depth + 1);
    await execute('SAVEPOINT $savePoint', []);

    try {
      final result = await transaction(tx);
      await execute('RELEASE SAVEPOINT $savePoint', []);
      return result;
    } catch (_) {
      await execute('ROLLBACK TO $savePoint', []);
      rethrow;
    }
  }

  @override
  Never rollback() => throw const TransactionRollback();
}

mixin _SessionDelegate<S extends Session> on Delegate {
  S get _session;

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) async {
    final result = await _session.execute(query, parameters: values);

    return DatabaseResult(
      columns: [...result.schema.columns.map((e) => e.columnName!)],
      rows: result,
      rowsAffected: result.affectedRows,
      lastInsertedRowId: null,
    );
  }
}
