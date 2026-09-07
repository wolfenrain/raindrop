import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/ddl.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_test/conformance.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  testDriverConformance(_NoNestingHarness());
}

/// A driver that declares its host cannot nest transactions, so the suite
/// skips the savepoint test instead of failing it.
class _NoNestingHarness extends DriverTestHarness {
  Database? _database;

  @override
  bool get supportsNestedTransactions => false;

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
