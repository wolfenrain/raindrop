import 'package:postgres/postgres.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

/// {@template postgres_delegate}
/// Delegate for the Postgres database.
/// {@endtemplate}
class PostgresDelegate extends RaindropDelegate with _SessionDelegate {
  /// {@macro postgres_delegate}
  ///
  /// Connect to the database at the [endpoint].
  PostgresDelegate(Uri endpoint)
      : this._(
          _openConnection(
            Endpoint(
              host: endpoint.host,
              port: endpoint.port,
              username: endpoint.userInfo.split(':').firstOrNull,
              password: endpoint.userInfo.split(':').lastOrNull,
              database: endpoint.pathSegments.first,
            ),
            ConnectionSettings(
              sslMode: switch (endpoint.queryParameters['sslmode']) {
                'require' => SslMode.require,
                'verify-full' => SslMode.verifyFull,
                'disable' || _ => SslMode.disable,
              },
              queryMode: switch (endpoint.queryParameters['querymode']) {
                'simple' => QueryMode.simple,
                'extended' || _ => QueryMode.extended,
              },
            ),
          ),
        );

  /// {@macro postgres_delegate}
  ///
  /// Connect to the database using the [endpoints] with the pooling mechanism.
  PostgresDelegate.pool(List<Uri> endpoints)
      : this._(
          _openPool(
            [
              for (final endpoint in endpoints)
                Endpoint(
                  host: endpoint.host,
                  port: endpoint.port,
                  username: endpoint.userInfo.split(':').firstOrNull,
                  password: endpoint.userInfo.split(':').lastOrNull,
                  database: endpoint.pathSegments.first,
                ),
            ],
            PoolSettings(
              sslMode: switch (endpoints[0].queryParameters['sslmode']) {
                'require' => SslMode.require,
                'verify-full' => SslMode.verifyFull,
                'disable' || _ => SslMode.disable,
              },
              queryMode: switch (endpoints[0].queryParameters['querymode']) {
                'simple' => QueryMode.simple,
                'extended' || _ => QueryMode.extended,
              },
            ),
          ),
        );

  PostgresDelegate._(this._opener) : super(dialect: const PostgresDialect());

  final Future<Session> Function() _opener;

  @override
  Session? _session;
  SessionExecutor? get _executor => _session as SessionExecutor?;

  @override
  Future<void> onOpen() async => _session = await _opener();

  @override
  Future<void> onClose() async => _executor?.close();

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    return _executor!.runTx((session) {
      return transaction(
        _TransactionDelegate(session, dialect),
      );
    });
  }

  static Future<Session> Function() _openConnection(
    Endpoint endpoint,
    ConnectionSettings settings,
  ) {
    return () => Connection.open(endpoint, settings: settings);
  }

  static Future<Session> Function() _openPool(
    List<Endpoint> endpoints,
    PoolSettings settings,
  ) {
    return () async =>
        Pool<dynamic>.withEndpoints(endpoints, settings: settings);
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
  S? get _session;

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) async {
    final result = await _session!.execute(query, parameters: values);

    return DatabaseResult(
      columns: [...result.schema.columns.map((e) => e.columnName!)],
      rows: result,
      rowsAffected: result.affectedRows,
      // lastInsertedRowId: _session!.
      lastInsertedRowId: null,
    );
  }
}
