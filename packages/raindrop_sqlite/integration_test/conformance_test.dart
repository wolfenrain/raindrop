import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/ddl.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_test/conformance.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  testDriverConformance(
    _SQLiteHarness(),
    returning: ReturningSupport(
      insert: (builder) => builder.returning(),
      update: (builder) => builder.returning(),
      delete: (builder) => builder.returning(),
    ),
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
  DdlGenerator createDdlGenerator() => const SQLiteDdlGenerator();

  @override
  Future<void> close(RaindropDelegate delegate) async {
    _database?.close();
    _database = null;
  }
}
