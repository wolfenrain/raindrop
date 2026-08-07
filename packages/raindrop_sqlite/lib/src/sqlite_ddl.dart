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
  String generate(List<DiffOperation> operations) {
    final altered = {
      for (final op in operations)
        if (op case final AlterTable alter) alter.tableName,
    };
    for (final op in operations) {
      if (op case final AlterTable alter when _needsRebuild(alter)) {
        for (final dependent in alter.referencedBy) {
          if (altered.contains(dependent.table.name)) {
            throw UnsupportedError(
              'Rebuilding "${alter.tableName}" must recreate '
              '"${dependent.table.name}", which is itself altered in this '
              'migration. Split the two changes into separate migrations.',
            );
          }
        }
      }
    }
    return super.generate(operations);
  }

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
    return _isSimple(operation, diff)
        ? _simpleAlter(operation, diff)
        : _rebuild(operation, diff);
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

  /// Whether every change fits SQLite's ALTER whitelist.
  bool _isSimple(AlterTable operation, TableDiff diff) {
    if (diff.changesDefinitions) return false;

    for (final column in diff.addedColumns) {
      final plainAdd = !column.primaryKey &&
          !column.autoIncrement &&
          column.foreignKey == null &&
          column.isNullable &&
          column.defaultValue == null;
      if (!plainAdd) return false;
    }

    for (final column in diff.droppedColumns) {
      // DROP COLUMN is rejected for key columns, indexed columns, columns in
      // a CHECK, and columns referenced from elsewhere.
      if (column.primaryKey || column.foreignKey != null) return false;
      final indexed = operation.oldIndexes
          .any((index) => index.columns.contains(column.name));
      if (indexed) return false;
      if (operation.oldTable.checks.isNotEmpty) return false;
      final referenced = operation.referencedBy.any(
        (dependent) => dependent.table.columns.any(
          (c) =>
              c.foreignKey?.referencedTable == operation.tableName &&
              c.foreignKey?.referencedColumn == column.name,
        ),
      );
      if (referenced) return false;
    }

    return true;
  }

  String _simpleAlter(AlterTable operation, TableDiff diff) {
    final table = escapeName(operation.tableName);
    return [
      for (final entry in operation.renamedColumns.entries)
        'ALTER TABLE $table RENAME COLUMN ${escapeName(entry.key)} '
            'TO ${escapeName(entry.value)};',
      for (final column in diff.droppedColumns)
        'ALTER TABLE $table DROP COLUMN ${escapeName(column.name)};',
      for (final column in diff.addedColumns)
        'ALTER TABLE $table ADD COLUMN ${_columnDefinition(column)};',
      for (final index in diff.droppedIndexes) dropIndex(index.name),
      for (final index in diff.addedIndexes) createIndex(index),
    ].join('\n');
  }

  String _rebuild(AlterTable operation, TableDiff diff) {
    for (final column in diff.addedColumns) {
      if (!column.isNullable && column.defaultValue == null) {
        throw UnsupportedError(
          'Adding NOT NULL column "${column.name}" to "${operation.tableName}" '
          'without a default: existing rows have no value to backfill. Give '
          'the column a default, or write the migration by hand with '
          '`generate --empty`.',
        );
      }
    }

    final rebuildSet = {
      operation.tableName,
      for (final dependent in operation.referencedBy) dependent.table.name,
    };

    final statements = <String>[
      'PRAGMA defer_foreign_keys = ON;',
      _createShadow(operation.newTable, rebuildSet),
      _copyTarget(operation, diff),
    ];

    // Dependents, byte-identical apart from re-targeted references.
    for (final dependent in operation.referencedBy) {
      statements
        ..add(_createShadow(dependent.table, rebuildSet))
        ..add(_copyVerbatim(dependent.table));
    }

    // Drop originals, a table only once nothing left references it.
    for (final name in _dropOrder(operation)) {
      statements.add('DROP TABLE ${escapeName(name)};');
    }

    // Rename shadows into place and restore the indexes.
    for (final name in rebuildSet) {
      statements.add(
        'ALTER TABLE ${escapeName('__new_$name')} RENAME TO '
        '${escapeName(name)};',
      );
    }
    statements.addAll([
      for (final index in operation.newIndexes) createIndex(index),
      for (final dependent in operation.referencedBy)
        for (final index in dependent.indexes) createIndex(index),
    ]);

    return statements.join('\n');
  }

  /// `CREATE TABLE "__new_<t>"` with references into [rebuildSet] pointed at
  /// their `__new_` names.
  String _createShadow(TableInfo table, Set<String> rebuildSet) {
    final defs = [
      for (final column in table.columns)
        _columnDefinition(
          column.foreignKey != null &&
                  rebuildSet.contains(column.foreignKey!.referencedTable)
              ? ColumnInfo(
                  name: column.name,
                  type: column.type,
                  isNullable: column.isNullable,
                  primaryKey: column.primaryKey,
                  autoIncrement: column.autoIncrement,
                  defaultValue: column.defaultValue,
                  foreignKey: ForeignKeyInfo(
                    referencedTable:
                        '__new_${column.foreignKey!.referencedTable}',
                    referencedColumn: column.foreignKey!.referencedColumn,
                    onDelete: column.foreignKey!.onDelete,
                    onUpdate: column.foreignKey!.onUpdate,
                  ),
                )
              : column,
        ),
      for (final entry in table.checks.entries)
        'CONSTRAINT ${escapeName(entry.key)} CHECK (${entry.value})',
    ].join(',\n  ');
    return 'CREATE TABLE ${escapeName('__new_${table.name}')} '
        '(\n  $defs\n);';
  }

  /// Copies the target's rows into its shadow: renamed columns read from
  /// their old name, added columns are omitted (their default applies),
  /// dropped columns are omitted on purpose.
  String _copyTarget(AlterTable operation, TableDiff diff) {
    final oldNameOf = {
      for (final entry in operation.renamedColumns.entries)
        entry.value: entry.key,
    };
    final copied = [
      for (final column in operation.newTable.columns)
        if (operation.oldTable.column(oldNameOf[column.name] ?? column.name) !=
            null)
          column.name,
    ];
    final targets = copied.map(escapeName).join(', ');
    final sources =
        copied.map((name) => escapeName(oldNameOf[name] ?? name)).join(', ');
    return 'INSERT INTO ${escapeName('__new_${operation.tableName}')} '
        '($targets) SELECT $sources FROM ${escapeName(operation.tableName)};';
  }

  String _copyVerbatim(TableInfo table) {
    final columns = table.columns.map((c) => escapeName(c.name)).join(', ');
    return 'INSERT INTO ${escapeName('__new_${table.name}')} ($columns) '
        'SELECT $columns FROM ${escapeName(table.name)};';
  }

  /// Original tables in a safe drop order: a table is dropped only after
  /// every rebuilt table referencing it is gone.
  List<String> _dropOrder(AlterTable operation) {
    final tables = {
      operation.tableName: operation.newTable,
      for (final dependent in operation.referencedBy)
        dependent.table.name: dependent.table,
    };

    final remaining = {...tables.keys};
    final order = <String>[];
    while (remaining.isNotEmpty) {
      final free = remaining.where((name) {
        return !remaining.any((other) {
          if (other == name) return false;
          return tables[other]!.columns.any(
                (column) => column.foreignKey?.referencedTable == name,
              );
        });
      }).toList();
      if (free.isEmpty) {
        throw UnsupportedError(
          'Cyclic foreign keys among ${remaining.join(', ')}: no safe order '
          'to rebuild them. Write the migration by hand with '
          '`generate --empty`.',
        );
      }
      order.addAll(free);
      remaining.removeAll(free);
    }
    return order;
  }

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

  /// Whether [operation] takes the rebuild path (vs the ALTER whitelist).
  bool _needsRebuild(AlterTable operation) =>
      !_isSimple(operation, TableDiff.of(operation));
}
