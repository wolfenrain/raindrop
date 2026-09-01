import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';
import 'package:raindrop/introspect.dart' as introspect;
import 'package:raindrop_test/src/conformance/fixtures.dart';
import 'package:raindrop_test/src/test_dialect.dart';

/// `CreateTable` operations for the conformance fixture tables, derived from
/// the fixture schemas through [introspect.buildSnapshot], so the tables a
/// driver is asked to create can never drift from the Dart schemas.
List<CreateTable> fixtureCreateTableOperations(SqlDialect dialect) {
  final snapshot = introspect.buildSnapshot(
    [users, pets],
    dialect: dialect,
    dialectName: const TestDialect().name,
  );
  return [for (final table in snapshot.tableInfos) CreateTable(table)];
}
