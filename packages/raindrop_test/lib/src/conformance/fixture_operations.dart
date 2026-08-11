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
  final tables = snapshot['tables']! as Map<String, Object?>;
  return [
    for (final table in tables.values)
      CreateTable(_tableInfo(table! as Map<String, Object?>)),
  ];
}

TableInfo _tableInfo(Map<String, Object?> table) {
  final columns = table['columns']! as Map<String, Object?>;
  return TableInfo(
    name: table['name']! as String,
    columns: [
      for (final column in columns.values.cast<Map<String, Object?>>())
        ColumnInfo(
          name: column['name']! as String,
          type: column['type']! as String,
          isNullable: column['isNullable']! as bool,
          primaryKey: column['primaryKey'] as bool? ?? false,
          autoIncrement: column['autoIncrement'] as bool? ?? false,
          defaultValue: column['default'] as String?,
        ),
    ],
  );
}
