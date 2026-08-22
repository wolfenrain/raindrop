import 'package:postgres/postgres.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/ddl.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:raindrop_test/conformance.dart';

void main() {
  testDriverConformance(
    _PostgresHarness(),
    returning: ReturningSupport(
      insert: (builder) => builder.returning(),
      update: (builder) => builder.returning(),
      delete: (builder) => builder.returning(),
    ),
  );
}

Future<Connection> _open() {
  return Connection.open(
    Endpoint(
      host: 'localhost',
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: const ConnectionSettings(
      sslMode: SslMode.disable,
      connectTimeout: Duration(seconds: 3),
    ),
  );
}

class _PostgresHarness extends DriverTestHarness {
  Connection? _connection;

  @override
  Future<bool> isAvailable() async {
    try {
      await (await _open()).close();
      return true;
      // ignore: avoid_catches_without_on_clauses anything thrown must skip
    } catch (_) {
      return false;
    }
  }

  @override
  Future<RaindropDelegate> open() async {
    final connection = _connection = await _open();
    return PostgresDelegate(connection);
  }

  @override
  DdlGenerator createDdlGenerator() => const PostgresDdlGenerator();

  @override
  Future<void> close(RaindropDelegate delegate) async {
    await _connection?.close();
    _connection = null;
  }
}
