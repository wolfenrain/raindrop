import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/ddl.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_test/conformance.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final harness = _SQLiteHarness();

  testDriverConformance(
    harness,
    returning: ReturningSupport(
      insert: (builder) => builder.returning(),
      update: (builder) => builder.returning(),
      delete: (builder) => builder.returning(),
    ),
  );
  final probe = sqliteTable('probe', UserSchema.new);
  testDriverContract(
    packageName: 'raindrop_sqlite',
    createDdlGenerator: harness.createDdlGenerator,
    probe: probe,
  );
}

class _SQLiteHarness extends DriverTestHarness {
  Database? _database;

  @override
  Future<RaindropDelegate> open() async {
    final database = _database = sqlite3.openInMemory();
    return SQLiteDelegate(database);
  }

  @override
  DdlGenerator createDdlGenerator() => SQLiteDdlGenerator();

  @override
  Future<void> close(RaindropDelegate delegate) async {
    _database?.close();
    _database = null;
  }
}
