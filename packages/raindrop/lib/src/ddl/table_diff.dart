import 'package:raindrop/ddl.dart';

/// {@template table_diff}
/// The mechanical decomposition of an [AlterTable] into its constituent
/// changes.
/// {@endtemplate}
class TableDiff {
  const TableDiff._({
    required this.addedColumns,
    required this.droppedColumns,
    required this.alteredColumns,
    required this.addedChecks,
    required this.droppedChecks,
    required this.changedChecks,
    required this.addedIndexes,
    required this.droppedIndexes,
  });

  /// Computes the diff carried by [operation].
  ///
  /// Renamed columns are matched old-name to new-name and never appear in
  /// [addedColumns] or [droppedColumns]. The differ only detects a rename
  /// between columns that are otherwise identical, so a renamed pair cannot
  /// appear in [alteredColumns] either.
  factory TableDiff.of(AlterTable operation) {
    final old = operation.oldTable;
    final new_ = operation.newTable;
    final renames = operation.renamedColumns;

    final added = <ColumnInfo>[];
    final dropped = <ColumnInfo>[];
    final altered = <(ColumnInfo, ColumnInfo)>[];

    for (final oldColumn in old.columns) {
      final newName = renames[oldColumn.name] ?? oldColumn.name;
      final newColumn = new_.column(newName);
      if (newColumn == null) {
        dropped.add(oldColumn);
      } else if (renames[oldColumn.name] == null && oldColumn != newColumn) {
        altered.add((oldColumn, newColumn));
      }
    }
    final consumed = {
      for (final oldColumn in old.columns)
        renames[oldColumn.name] ?? oldColumn.name,
    };
    for (final newColumn in new_.columns) {
      if (!consumed.contains(newColumn.name)) added.add(newColumn);
    }

    final addedChecks = <String, String>{};
    final droppedChecks = <String, String>{};
    final changedChecks = <String, (String, String)>{};
    for (final entry in old.checks.entries) {
      final replacement = new_.checks[entry.key];
      if (replacement == null) {
        droppedChecks[entry.key] = entry.value;
      } else if (replacement != entry.value) {
        changedChecks[entry.key] = (entry.value, replacement);
      }
    }
    for (final entry in new_.checks.entries) {
      if (!old.checks.containsKey(entry.key)) {
        addedChecks[entry.key] = entry.value;
      }
    }

    // A changed index is a drop plus a create, matched by name.
    final oldIndexes = {for (final i in operation.oldIndexes) i.name: i};
    final newIndexes = {for (final i in operation.newIndexes) i.name: i};
    final addedIndexes = <IndexInfo>[];
    final droppedIndexes = <IndexInfo>[];
    for (final index in operation.oldIndexes) {
      final replacement = newIndexes[index.name];
      if (replacement == null || replacement != index) {
        droppedIndexes.add(index);
      }
    }
    for (final index in operation.newIndexes) {
      final previous = oldIndexes[index.name];
      if (previous == null || previous != index) addedIndexes.add(index);
    }

    return TableDiff._(
      addedColumns: added,
      droppedColumns: dropped,
      alteredColumns: altered,
      addedChecks: addedChecks,
      droppedChecks: droppedChecks,
      changedChecks: changedChecks,
      addedIndexes: addedIndexes,
      droppedIndexes: droppedIndexes,
    );
  }

  /// Columns present only in the new table (renames excluded).
  final List<ColumnInfo> addedColumns;

  /// Columns present only in the old table (renames excluded).
  final List<ColumnInfo> droppedColumns;

  /// Columns present in both whose definition changed, as (old, new).
  final List<(ColumnInfo, ColumnInfo)> alteredColumns;

  /// CHECK constraints present only in the new table, by name.
  final Map<String, String> addedChecks;

  /// CHECK constraints present only in the old table, by name.
  final Map<String, String> droppedChecks;

  /// CHECK constraints whose expression changed, name to (old, new).
  final Map<String, (String, String)> changedChecks;

  /// Indexes to create (new, or the create half of a changed index).
  final List<IndexInfo> addedIndexes;

  /// Indexes to drop (gone, or the drop half of a changed index).
  final List<IndexInfo> droppedIndexes;

  /// Whether the change touches column definitions or checks, the changes a
  /// dialect without a general ALTER COLUMN must rebuild for.
  bool get changesDefinitions =>
      alteredColumns.isNotEmpty ||
      addedChecks.isNotEmpty ||
      droppedChecks.isNotEmpty ||
      changedChecks.isNotEmpty;
}
