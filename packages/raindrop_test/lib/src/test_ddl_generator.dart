import 'package:raindrop/ddl.dart';
import 'package:raindrop_test/src/test_dialect.dart';

/// {@template test_ddl_generator}
/// A minimal [DdlGenerator] over the [TestDialect], just enough for code
/// that renders DDL through a delegate (like migration storage) to run
/// against a `TestDelegate`.
///
/// It renders creates and drops in generic SQL, and refuses [alterTable],
/// which no test double can meaningfully apply.
/// {@endtemplate}
class TestDdlGenerator extends DdlGenerator {
  /// {@macro test_ddl_generator}
  const TestDdlGenerator() : super(dialect: const TestDialect());

  @override
  String createTable(TableInfo table, {bool ifNotExists = false}) {
    final defs = [
      for (final column in table.columns)
        [
          escapeName(column.name),
          getColumnType(column),
          if (column.primaryKey) 'PRIMARY KEY',
          if (!column.isNullable) 'NOT NULL',
        ].join(' '),
    ].join(',\n  ');
    final exists = ifNotExists ? 'IF NOT EXISTS ' : '';
    return 'CREATE TABLE $exists${escapeName(table.name)} (\n  $defs\n);';
  }

  @override
  String dropTable(String tableName) => 'DROP TABLE ${escapeName(tableName)};';

  @override
  String alterTable(AlterTable operation) => throw UnsupportedError(
        'TestDdlGenerator does not render table changes.',
      );

  @override
  String createIndex(IndexInfo index, {bool ifNotExists = false}) {
    final unique = index.isUnique ? 'UNIQUE ' : '';
    final exists = ifNotExists ? 'IF NOT EXISTS ' : '';
    final cols = index.columns.map(escapeName).join(', ');
    return '''
CREATE ${unique}INDEX $exists${escapeName(index.name)} ON ${escapeName(index.tableName)} ($cols);''';
  }

  @override
  String dropIndex(String indexName) => 'DROP INDEX ${escapeName(indexName)};';

  @override
  String getColumnType(ColumnInfo column) => column.type;
}
