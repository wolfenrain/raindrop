import 'package:raindrop/ddl.dart';
import 'package:raindrop/snapshot.dart';

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

    // Dropped tables. Their indexes die with them, so the index pass below
    // must not emit a DropIndex that would run after the table is gone. A
    // referencing table drops before the table it references, so no foreign
    // key ever points at a table that is already gone.
    final dropped = [
      for (final entry in oldTables.entries)
        if (!newTables.containsKey(entry.key)) entry.value,
    ];
    for (final table in _referencedFirst(dropped).reversed) {
      operations.add(DropTable(table.name));
    }

    // Created tables, referenced tables first, so no foreign key ever points
    // at a table that does not exist yet.
    final created = [
      for (final entry in newTables.entries)
        if (!oldTables.containsKey(entry.key)) entry.value,
    ];
    for (final table in _referencedFirst(created)) {
      operations.add(CreateTable(table.toTableInfo()));
    }

    // Tables whose intra-table state is reconciled by an AlterTable, their
    // index changes travel ON the operation rather than as global index ops,
    // so exactly one operation owns each table's reconciliation.
    final altered = <String>{};

    for (final entry in newTables.entries) {
      final tableName = entry.key;
      final newTable = entry.value;

      if (!oldTables.containsKey(tableName)) continue;

      final oldTable = oldTables[tableName]!;
      final tableOldIndexes = _tableIndexes(oldIndexes, tableName);
      final tableNewIndexes = _tableIndexes(newIndexes, tableName);

      final changed = !_sameColumns(oldTable, newTable) ||
          !_sameChecks(oldTable, newTable) ||
          !_sameIndexes(tableOldIndexes, tableNewIndexes);
      if (!changed) continue;

      altered.add(tableName);
      operations.add(
        AlterTable(
          oldTable: oldTable.toTableInfo(),
          newTable: newTable.toTableInfo(),
          renamedColumns: _detectRenames(oldTable, newTable),
          oldIndexes: tableOldIndexes,
          newIndexes: tableNewIndexes,
          referencedBy: _referencedByClosure(to, tableName),
        ),
      );
    }

    operations.addAll(
      _diffIndexes(oldIndexes, newIndexes, skipTables: {
        ...altered,
        // Dropped tables' indexes are gone already.
        for (final name in oldTables.keys)
          if (!newTables.containsKey(name)) name,
      }),
    );

    return operations;
  }

  bool _sameColumns(TableSnapshot old, TableSnapshot new_) =>
      old.columns.length == new_.columns.length &&
      old.columns.entries.every((e) => new_.columns[e.key] == e.value);

  bool _sameChecks(TableSnapshot old, TableSnapshot new_) =>
      old.checks.length == new_.checks.length &&
      old.checks.entries.every((e) => new_.checks[e.key] == e.value);

  bool _sameIndexes(List<IndexInfo> old, List<IndexInfo> new_) {
    if (old.length != new_.length) return false;
    final byName = {for (final index in new_) index.name: index};
    return old.every((index) => byName[index.name] == index);
  }

  /// The indexes of [tableName], in snapshot order.
  List<IndexInfo> _tableIndexes(
    Map<String, IndexSnapshot> indexes,
    String tableName,
  ) =>
      [
        for (final index in indexes.values)
          if (index.tableName == tableName) index.toIndexInfo(),
      ];

  /// The transitive closure of tables whose foreign keys reference
  /// [tableName], in the new schema, each with its indexes.
  List<ReferencedBy> _referencedByClosure(SchemaSnapshot to, String tableName) {
    final result = <ReferencedBy>[];
    final seen = {tableName};
    var frontier = {tableName};

    while (frontier.isNotEmpty) {
      final next = <String>{};
      for (final entry in to.tables.entries) {
        if (seen.contains(entry.key)) continue;
        final references = entry.value.columns.values.any(
          (column) => frontier.contains(column.foreignKey?.referencedTable),
        );
        if (references) {
          seen.add(entry.key);
          next.add(entry.key);
          result.add(
            ReferencedBy(
              table: entry.value.toTableInfo(),
              indexes: _tableIndexes(to.indexes, entry.key),
            ),
          );
        }
      }
      frontier = next;
    }

    return result;
  }

  /// Index operations for tables not owned by an [AlterTable] this run.
  List<DiffOperation> _diffIndexes(
    Map<String, IndexSnapshot> oldIndexes,
    Map<String, IndexSnapshot> newIndexes, {
    required Set<String> skipTables,
  }) {
    final operations = <DiffOperation>[];

    for (final entry in oldIndexes.entries) {
      if (skipTables.contains(entry.value.tableName)) continue;
      if (!newIndexes.containsKey(entry.key)) {
        operations.add(DropIndex(entry.key, tableName: entry.value.tableName));
      }
    }

    for (final entry in newIndexes.entries) {
      final name = entry.key;
      final newIndex = entry.value;
      if (skipTables.contains(newIndex.tableName)) continue;

      final oldIndex = oldIndexes[name];
      if (oldIndex == null) {
        operations.add(CreateIndex(index: newIndex.toIndexInfo()));
      } else if (oldIndex != newIndex) {
        // Changed index - drop and recreate
        operations
          ..add(DropIndex(name, tableName: newIndex.tableName))
          ..add(CreateIndex(index: newIndex.toIndexInfo()));
      }
    }

    return operations;
  }

  /// Detects column renames: a column that disappeared and a column that
  /// appeared with an identical definition are treated as one rename.
  Map<String, String> _detectRenames(TableSnapshot old, TableSnapshot new_) {
    final dropped = [
      for (final column in old.columns.values)
        if (!new_.columns.containsKey(column.name)) column,
    ];
    final added = [
      for (final column in new_.columns.values)
        if (!old.columns.containsKey(column.name)) column,
    ];

    final renames = <String, String>{};
    final claimed = <ColumnSnapshot>{};
    for (final from in dropped) {
      for (final to in added) {
        if (claimed.contains(to)) continue;
        if (_columnsMatchForRename(from, to)) {
          renames[from.name] = to.name;
          claimed.add(to);
          break;
        }
      }
    }
    return renames;
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
}

/// Orders [tables] so every table follows the tables its foreign keys
/// reference, when those are also in [tables].
///
/// A reference cycle cannot be ordered, those tables keep their given order
/// and the driver decides what to do with them.
List<TableSnapshot> _referencedFirst(List<TableSnapshot> tables) {
  final byName = {for (final table in tables) table.name: table};
  final ordered = <TableSnapshot>[];
  final visited = <String>{};

  void visit(TableSnapshot table) {
    if (!visited.add(table.name)) return;
    for (final column in table.columns.values) {
      final referenced = byName[column.foreignKey?.referencedTable];
      if (referenced != null && referenced.name != table.name) {
        visit(referenced);
      }
    }
    ordered.add(table);
  }

  tables.forEach(visit);
  return ordered;
}
