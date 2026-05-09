import 'package:raindrop/ddl.dart';

import 'package:raindrop_cli/src/core/snapshot.dart';

/// Calculates the diff between two schema snapshots.
class SchemaDiffer {
  /// Calculates the list of operations needed to transform [from] into [to].
  ///
  /// If [from] is null, all tables in [to] are considered as new.
  List<DiffOperation> diff(SchemaSnapshot? from, SchemaSnapshot to) {
    final operations = <DiffOperation>[];

    final oldTables = from?.tables ?? {};
    final newTables = to.tables;
    final oldIndexes = from?.indexes ?? {};
    final newIndexes = to.indexes;

    // Find dropped tables
    for (final tableName in oldTables.keys) {
      if (!newTables.containsKey(tableName)) {
        operations.add(DropTable(tableName));
      }
    }

    // Find new and modified tables
    for (final entry in newTables.entries) {
      final tableName = entry.key;
      final newTable = entry.value;

      if (!oldTables.containsKey(tableName)) {
        // New table
        operations.add(CreateTable(
          tableName: tableName,
          columns: newTable.columns.values.map(_toColumnInfo).toList(),
        ));
      } else {
        // Existing table - check for column changes
        final oldTable = oldTables[tableName]!;
        operations.addAll(_diffTable(tableName, oldTable, newTable));
      }
    }

    // Diff indexes
    operations.addAll(_diffIndexes(oldIndexes, newIndexes));

    return operations;
  }

  /// Calculates the list of index operations needed.
  List<DiffOperation> _diffIndexes(
    Map<String, IndexSnapshot> oldIndexes,
    Map<String, IndexSnapshot> newIndexes,
  ) {
    final operations = <DiffOperation>[];

    // Find dropped indexes
    for (final name in oldIndexes.keys) {
      if (!newIndexes.containsKey(name)) {
        operations.add(DropIndex(name));
      }
    }

    // Find new or changed indexes
    for (final entry in newIndexes.entries) {
      final name = entry.key;
      final newIndex = entry.value;
      final oldIndex = oldIndexes[name];

      if (oldIndex == null) {
        // New index
        operations.add(CreateIndex(index: _toIndexInfo(newIndex)));
      } else if (oldIndex != newIndex) {
        // Changed index - drop and recreate
        operations.add(DropIndex(name));
        operations.add(CreateIndex(index: _toIndexInfo(newIndex)));
      }
    }

    return operations;
  }

  /// Converts an [IndexSnapshot] to an [IndexInfo].
  IndexInfo _toIndexInfo(IndexSnapshot snapshot) {
    return IndexInfo(
      name: snapshot.name,
      tableName: snapshot.tableName,
      columns: List<String>.from(snapshot.columns),
      isUnique: snapshot.isUnique,
      where: snapshot.where,
    );
  }

  /// Calculates column-level diff for a table.
  List<DiffOperation> _diffTable(
    String tableName,
    TableSnapshot oldTable,
    TableSnapshot newTable,
  ) {
    final operations = <DiffOperation>[];

    final oldColumns = Map<String, ColumnSnapshot>.from(oldTable.columns);
    final newColumns = Map<String, ColumnSnapshot>.from(newTable.columns);

    // First, find columns that exist in both (possibly modified)
    final matchedOldColumns = <String>{};
    final matchedNewColumns = <String>{};

    for (final oldName in oldColumns.keys) {
      if (newColumns.containsKey(oldName)) {
        matchedOldColumns.add(oldName);
        matchedNewColumns.add(oldName);

        final oldColumn = oldColumns[oldName]!;
        final newColumn = newColumns[oldName]!;
        if (oldColumn != newColumn) {
          operations.add(AlterColumn(
            tableName,
            _toColumnInfo(oldColumn),
            _toColumnInfo(newColumn),
          ));
        }
      }
    }

    // Find dropped and added columns
    final droppedColumns = oldColumns.keys
        .where((name) => !matchedOldColumns.contains(name))
        .map((name) => oldColumns[name]!)
        .toList();
    final addedColumns = newColumns.keys
        .where((name) => !matchedNewColumns.contains(name))
        .map((name) => newColumns[name]!)
        .toList();

    // Try to detect renames: match dropped columns with added columns
    // that have the same type and constraints
    final renamedFrom = <ColumnSnapshot>{};
    final renamedTo = <ColumnSnapshot>{};

    for (final dropped in droppedColumns) {
      for (final added in addedColumns) {
        if (renamedTo.contains(added)) continue;

        if (_columnsMatchForRename(dropped, added)) {
          operations.add(RenameColumn(tableName, dropped.name, added.name));
          renamedFrom.add(dropped);
          renamedTo.add(added);
          break;
        }
      }
    }

    // Add remaining drops and adds
    for (final dropped in droppedColumns) {
      if (!renamedFrom.contains(dropped)) {
        operations.add(DropColumn(tableName, dropped.name));
      }
    }

    for (final added in addedColumns) {
      if (!renamedTo.contains(added)) {
        operations.add(AddColumn(tableName, _toColumnInfo(added)));
      }
    }

    return operations;
  }

  /// Checks if two columns match for a potential rename operation.
  ///
  /// Columns match if they have the same type, nullability, primary key status,
  /// auto-increment setting, default value, and foreign key reference.
  bool _columnsMatchForRename(ColumnSnapshot old, ColumnSnapshot new_) {
    return old.type == new_.type &&
        old.isNullable == new_.isNullable &&
        old.primaryKey == new_.primaryKey &&
        old.autoIncrement == new_.autoIncrement &&
        old.defaultValue == new_.defaultValue &&
        old.foreignKey == new_.foreignKey;
  }

  /// Converts a [ColumnSnapshot] to a [ColumnInfo].
  ColumnInfo _toColumnInfo(ColumnSnapshot snapshot) {
    return ColumnInfo(
      name: snapshot.name,
      type: snapshot.type,
      isNullable: snapshot.isNullable,
      primaryKey: snapshot.primaryKey,
      autoIncrement: snapshot.autoIncrement,
      defaultValue: snapshot.defaultValue,
      foreignKey: switch (snapshot.foreignKey) {
        ForeignKeySnapshotRef foreignKey => ForeignKeyInfo(
            referencedTable: foreignKey.referencedTable,
            referencedColumn: foreignKey.referencedColumn,
            onDelete: foreignKey.onDelete,
            onUpdate: foreignKey.onUpdate,
          ),
        _ => null,
      },
    );
  }
}
