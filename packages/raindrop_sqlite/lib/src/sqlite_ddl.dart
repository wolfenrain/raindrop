import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop_sqlite/src/sqlite_dialect.dart';

void main(List<String> args, SendPort sendPort) => SQLiteDdlGenerator(sendPort);

/// {@template sqlite_ddl_generator}
/// DDL generator for SQLite.
/// {@endtemplate}
class SQLiteDdlGenerator extends DdlGenerator {
  /// {@macro sqlite_ddl_generator}
  SQLiteDdlGenerator(super.sendPort) : super(dialect: const SQLiteDialect());

  @override
  String createTable(String tableName, List<ColumnInfo> columns) {
    final columnDefs = columns.map(_columnDefinition).join(',\n  ');
    return 'CREATE TABLE ${escapeName(tableName)} (\n  $columnDefs\n);';
  }

  @override
  String renameTable(String oldName, String newName) {
    return 'ALTER TABLE ${escapeName(oldName)} RENAME TO ${escapeName(newName)};';
  }

  @override
  String dropTable(String tableName) {
    return 'DROP TABLE ${escapeName(tableName)};';
  }

  @override
  String addColumn(String tableName, ColumnInfo column) {
    return 'ALTER TABLE ${escapeName(tableName)} ADD COLUMN ${_columnDefinition(column)};';
  }

  @override
  String renameColumn(String tableName, String oldName, String newName) {
    return 'ALTER TABLE ${escapeName(tableName)} RENAME COLUMN ${escapeName(oldName)} TO ${escapeName(newName)};';
  }

  @override
  String dropColumn(String tableName, String columnName) {
    return 'ALTER TABLE ${escapeName(tableName)} DROP COLUMN ${escapeName(columnName)};';
  }

  @override
  String alterColumn(
    String tableName,
    ColumnInfo oldColumn,
    ColumnInfo newColumn,
  ) {
    final statements = <String>[];
    final table = escapeName(tableName);
    final column = escapeName(newColumn.name);

    // Type change
    if (oldColumn.type != newColumn.type) {
      statements.add(
        'ALTER TABLE $table ALTER COLUMN $column TYPE ${getColumnType(newColumn)};',
      );
    }

    // Nullability change
    if (oldColumn.isNullable != newColumn.isNullable) {
      if (newColumn.isNullable) {
        statements.add(
          'ALTER TABLE $table ALTER COLUMN $column DROP NOT NULL;',
        );
      } else {
        statements.add(
          'ALTER TABLE $table ALTER COLUMN $column SET NOT NULL;',
        );
      }
    }

    // Default value change
    if (oldColumn.defaultValue != newColumn.defaultValue) {
      if (newColumn.defaultValue == null) {
        statements.add(
          'ALTER TABLE $table ALTER COLUMN $column DROP DEFAULT;',
        );
      } else {
        statements.add(
          'ALTER TABLE $table ALTER COLUMN $column SET DEFAULT ${newColumn.defaultValue};',
        );
      }
    }

    return statements.join('\n');
  }

  @override
  String createIndex(IndexInfo index) {
    final unique = index.isUnique ? 'UNIQUE ' : '';
    final cols = index.columns.map(escapeName).join(', ');
    final where = index.where != null ? ' WHERE ${index.where}' : '';
    return 'CREATE ${unique}INDEX ${escapeName(index.name)} '
        'ON ${escapeName(index.tableName)} ($cols)$where;';
  }

  @override
  String dropIndex(String indexName) {
    return 'DROP INDEX ${escapeName(indexName)};';
  }

  @override
  String getColumnType(ColumnInfo column) => column.type;

  String _columnDefinition(ColumnInfo column) {
    final parts = <String>[
      escapeName(column.name),
      getColumnType(column),
    ];

    if (column.primaryKey) {
      parts.add('PRIMARY KEY');
      if (column.autoIncrement) {
        parts.add('AUTOINCREMENT');
      }
    }

    if (!column.isNullable && !column.primaryKey) {
      parts.add('NOT NULL');
    }

    if (column.defaultValue != null) {
      parts.add('DEFAULT ${column.defaultValue}');
    }

    if (column.foreignKey case final fk?) {
      parts.add(
        'REFERENCES ${escapeName(fk.referencedTable)}(${escapeName(fk.referencedColumn)})',
      );
      if (fk.onDelete != null) parts.add('ON DELETE ${fk.onDelete}');
      if (fk.onUpdate != null) parts.add('ON UPDATE ${fk.onUpdate}');
    }

    return parts.join(' ');
  }
}
