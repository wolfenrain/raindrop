import 'package:raindrop/ddl.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

/// {@template postgres_ddl_generator}
/// DDL generator for PostgreSQL.
/// {@endtemplate}
class PostgresDdlGenerator extends DdlGenerator {
  /// {@macro postgres_ddl_generator}
  const PostgresDdlGenerator() : super(dialect: const PostgresDialect());

  @override
  String createTable(TableInfo table) {
    final defs = [
      ...table.columns.map(_columnDefinition),
      for (final entry in table.checks.entries)
        'CONSTRAINT ${escapeName(entry.key)} CHECK (${entry.value})',
    ].join(',\n  ');
    return 'CREATE TABLE ${escapeName(table.name)} (\n  $defs\n);';
  }

  @override
  String dropTable(String tableName) {
    return 'DROP TABLE ${escapeName(tableName)};';
  }

  @override
  String alterTable(AlterTable operation) {
    final diff = TableDiff.of(operation);
    final table = escapeName(operation.tableName);
    final statements = <String>[
      ...operation.renamedColumns.entries.map(
        (entry) => '''
ALTER TABLE $table RENAME COLUMN ${escapeName(entry.key)} TO ${escapeName(entry.value)};''',
      ),
      for (final column in diff.droppedColumns)
        'ALTER TABLE $table DROP COLUMN ${escapeName(column.name)};',
      for (final column in diff.addedColumns)
        'ALTER TABLE $table ADD COLUMN ${_columnDefinition(column)};',
    ];

    for (final (old, new_) in diff.alteredColumns) {
      statements.addAll(_alterColumn(operation.tableName, old, new_));
    }

    statements.addAll([
      for (final name in {
        ...diff.droppedChecks.keys,
        ...diff.changedChecks.keys,
      })
        'ALTER TABLE $table DROP CONSTRAINT ${escapeName(name)};',
      ...{
        ...diff.addedChecks,
        for (final changed in diff.changedChecks.entries)
          changed.key: changed.value.$2,
      }.entries.map(
            (entry) => '''
ALTER TABLE $table ADD CONSTRAINT ${escapeName(entry.key)} CHECK (${entry.value});''',
          ),
      for (final index in diff.droppedIndexes) dropIndex(index.name),
      for (final index in diff.addedIndexes) createIndex(index),
    ]);

    return statements.join('\n');
  }

  /// One column's in-place changes.
  ///
  /// A foreign-key change drops and re-adds the constraint under postgres's
  /// default name for an inline reference, `<table>_<column>_fkey`, so it
  /// also matches constraints created before raindrop named them.
  List<String> _alterColumn(
    String tableName,
    ColumnInfo oldColumn,
    ColumnInfo newColumn,
  ) {
    if (oldColumn.primaryKey != newColumn.primaryKey ||
        oldColumn.autoIncrement != newColumn.autoIncrement) {
      throw UnsupportedError(
        '''
Changing the primary key or auto-increment of "$tableName"."${newColumn.name}" is not generated automatically. Write the migration by hand with `generate --empty`.''',
      );
    }

    final table = escapeName(tableName);
    final column = escapeName(newColumn.name);
    final statements = <String>[];

    if (oldColumn.type != newColumn.type) {
      statements.add(
        '''
ALTER TABLE $table ALTER COLUMN $column TYPE ${getColumnType(newColumn)};''',
      );
    }

    if (oldColumn.isNullable != newColumn.isNullable) {
      statements.add(
        newColumn.isNullable
            ? 'ALTER TABLE $table ALTER COLUMN $column DROP NOT NULL;'
            : 'ALTER TABLE $table ALTER COLUMN $column SET NOT NULL;',
      );
    }

    if (oldColumn.defaultValue != newColumn.defaultValue) {
      statements.add(
        newColumn.defaultValue == null
            ? 'ALTER TABLE $table ALTER COLUMN $column DROP DEFAULT;'
            : '''
ALTER TABLE $table ALTER COLUMN $column SET DEFAULT ${newColumn.defaultValue};''',
      );
    }

    if (oldColumn.foreignKey != newColumn.foreignKey) {
      final constraint = escapeName('${tableName}_${newColumn.name}_fkey');
      if (oldColumn.foreignKey != null) {
        statements.add('ALTER TABLE $table DROP CONSTRAINT $constraint;');
      }
      if (newColumn.foreignKey case final fk?) {
        final actions = [
          if (fk.onDelete != null) ' ON DELETE ${fk.onDelete}',
          if (fk.onUpdate != null) ' ON UPDATE ${fk.onUpdate}',
        ].join();
        statements.add(
          '''
ALTER TABLE $table ADD CONSTRAINT $constraint FOREIGN KEY ($column) REFERENCES ${escapeName(fk.referencedTable)}(${escapeName(fk.referencedColumn)})$actions;''',
        );
      }
    }

    return statements;
  }

  @override
  String createIndex(IndexInfo index) {
    final unique = index.isUnique ? 'UNIQUE ' : '';
    final cols = index.columns.map(escapeName).join(', ');
    final where = index.where != null ? ' WHERE ${index.where}' : '';
    return '''
CREATE ${unique}INDEX ${escapeName(index.name)} ON ${escapeName(index.tableName)} ($cols)$where;''';
  }

  @override
  String dropIndex(String indexName) {
    return 'DROP INDEX ${escapeName(indexName)};';
  }

  @override
  String getColumnType(ColumnInfo column) {
    // Handle auto-increment integer primary keys as SERIAL
    if (column.primaryKey && column.autoIncrement && column.type == 'INTEGER') {
      return 'SERIAL';
    }
    return column.type;
  }

  String _columnDefinition(ColumnInfo column) {
    final parts = <String>[
      escapeName(column.name),
      getColumnType(column),
    ];

    if (column.primaryKey) {
      parts.add('PRIMARY KEY');
    }

    if (!column.isNullable && !column.primaryKey) {
      parts.add('NOT NULL');
    }

    if (column.defaultValue != null) {
      parts.add('DEFAULT ${column.defaultValue}');
    }

    if (column.foreignKey case final fk?) {
      parts.add(
        '''
REFERENCES ${escapeName(fk.referencedTable)}(${escapeName(fk.referencedColumn)})''',
      );
      if (fk.onDelete != null) parts.add('ON DELETE ${fk.onDelete}');
      if (fk.onUpdate != null) parts.add('ON UPDATE ${fk.onUpdate}');
    }

    return parts.join(' ');
  }
}
