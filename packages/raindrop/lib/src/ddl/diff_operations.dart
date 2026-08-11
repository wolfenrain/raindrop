import 'package:raindrop/ddl.dart';

/// {@template diff_operation}
/// Base class for schema diff operations.
/// {@endtemplate}
sealed class DiffOperation {
  /// {@macro diff_operation}
  const DiffOperation();

  /// Returns a human-readable description of the operation.
  String describe();

  /// Converts this operation to a map representation for serialization.
  Map<String, dynamic> toMap();

  /// Creates a [DiffOperation] from a map representation.
  static DiffOperation fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;
    return switch (type) {
      'createTable' => CreateTable.fromMap(map),
      'dropTable' => DropTable.fromMap(map),
      'alterTable' => AlterTable.fromMap(map),
      'createIndex' => CreateIndex.fromMap(map),
      'dropIndex' => DropIndex.fromMap(map),
      _ => throw ArgumentError('Unknown operation type: $type'),
    };
  }
}

/// {@template create_table}
/// Operation to create a new table.
/// {@endtemplate}
class CreateTable extends DiffOperation {
  /// {@macro create_table}
  const CreateTable(this.table);

  /// Creates a [CreateTable] from a map representation.
  factory CreateTable.fromMap(Map<String, dynamic> map) {
    return CreateTable(TableInfo.fromMap(map['table'] as Map<String, dynamic>));
  }

  /// The table to create, in full.
  final TableInfo table;

  @override
  String describe() => 'Create table "${table.name}"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'createTable',
      'table': table.toMap(),
    };
  }
}

/// {@template drop_table}
/// Operation to drop a table.
/// {@endtemplate}
class DropTable extends DiffOperation {
  /// {@macro drop_table}
  const DropTable(this.tableName);

  /// Creates a [DropTable] from a map representation.
  factory DropTable.fromMap(Map<String, dynamic> map) {
    return DropTable(map['tableName'] as String);
  }

  /// The name of the table to drop.
  final String tableName;

  @override
  String describe() => 'Drop table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'dropTable',
      'tableName': tableName,
    };
  }
}

/// {@template alter_table}
/// Operation carrying every intra-table change as one unit: the full old and
/// new definitions, detected column renames, the table's indexes on both
/// sides, and the tables whose foreign keys reference it.
/// {@endtemplate}
class AlterTable extends DiffOperation {
  /// {@macro alter_table}
  const AlterTable({
    required this.oldTable,
    required this.newTable,
    this.renamedColumns = const {},
    this.oldIndexes = const [],
    this.newIndexes = const [],
    this.referencedBy = const [],
  });

  /// Creates an [AlterTable] from a map representation.
  factory AlterTable.fromMap(Map<String, dynamic> map) {
    return AlterTable(
      oldTable: TableInfo.fromMap(map['oldTable'] as Map<String, dynamic>),
      newTable: TableInfo.fromMap(map['newTable'] as Map<String, dynamic>),
      renamedColumns: Map<String, String>.from(
        map['renamedColumns'] as Map<String, dynamic>? ?? {},
      ),
      oldIndexes: _indexes(map['oldIndexes']),
      newIndexes: _indexes(map['newIndexes']),
      referencedBy: (map['referencedBy'] as List<dynamic>? ?? [])
          .map((r) => ReferencedBy.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<IndexInfo> _indexes(Object? value) => [
        for (final index in value as List<dynamic>? ?? <dynamic>[])
          IndexInfo.fromMap(index as Map<String, dynamic>),
      ];

  /// The table definition before the change.
  final TableInfo oldTable;

  /// The table definition after the change.
  final TableInfo newTable;

  /// Detected column renames, old name to new name.
  final Map<String, String> renamedColumns;

  /// This table's indexes before the change.
  final List<IndexInfo> oldIndexes;

  /// This table's indexes after the change.
  final List<IndexInfo> newIndexes;

  /// The transitive closure of tables whose foreign keys reference this one,
  /// in their (unchanged) new-schema form. See [ReferencedBy] for why.
  final List<ReferencedBy> referencedBy;

  /// The table's name (unchanged by this operation).
  String get tableName => newTable.name;

  @override
  String describe() {
    final diff = TableDiff.of(this);
    final parts = [
      for (final entry in renamedColumns.entries)
        'rename column "${entry.key}" to "${entry.value}"',
      for (final column in diff.addedColumns) 'add column "${column.name}"',
      for (final column in diff.droppedColumns) 'drop column "${column.name}"',
      for (final (old, _) in diff.alteredColumns) 'alter column "${old.name}"',
      for (final name in diff.addedChecks.keys) 'add check "$name"',
      for (final name in diff.droppedChecks.keys) 'drop check "$name"',
      for (final name in diff.changedChecks.keys) 'change check "$name"',
      for (final index in diff.addedIndexes) 'add index "${index.name}"',
      for (final index in diff.droppedIndexes) 'drop index "${index.name}"',
    ];
    return 'Alter table "$tableName" (${parts.join(', ')})';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'alterTable',
      'oldTable': oldTable.toMap(),
      'newTable': newTable.toMap(),
      if (renamedColumns.isNotEmpty) 'renamedColumns': renamedColumns,
      if (oldIndexes.isNotEmpty)
        'oldIndexes': oldIndexes.map((i) => i.toMap()).toList(),
      if (newIndexes.isNotEmpty)
        'newIndexes': newIndexes.map((i) => i.toMap()).toList(),
      if (referencedBy.isNotEmpty)
        'referencedBy': referencedBy.map((r) => r.toMap()).toList(),
    };
  }
}

/// {@template create_index}
/// Operation to create an index.
/// {@endtemplate}
class CreateIndex extends DiffOperation {
  /// {@macro create_index}
  const CreateIndex({required this.index});

  /// Creates a [CreateIndex] from a map representation.
  factory CreateIndex.fromMap(Map<String, dynamic> map) {
    return CreateIndex(
      index: IndexInfo.fromMap(map['index'] as Map<String, dynamic>),
    );
  }

  /// The index to create.
  final IndexInfo index;

  @override
  String describe() => '''
Create ${index.isUnique ? 'unique ' : ''}index "${index.name}" on table "${index.tableName}"''';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'createIndex',
      'index': index.toMap(),
    };
  }
}

/// {@template drop_index}
/// Operation to drop an index.
/// {@endtemplate}
class DropIndex extends DiffOperation {
  /// {@macro drop_index}
  const DropIndex(this.indexName, {required this.tableName});

  /// Creates a [DropIndex] from a map representation.
  factory DropIndex.fromMap(Map<String, dynamic> map) {
    return DropIndex(
      map['indexName'] as String,
      tableName: map['tableName'] as String,
    );
  }

  /// The name of the index to drop.
  final String indexName;

  /// The table the index belongs to.
  final String tableName;

  @override
  String describe() => 'Drop index "$indexName" on table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'dropIndex',
      'indexName': indexName,
      'tableName': tableName,
    };
  }
}
