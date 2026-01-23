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
      'addColumn' => AddColumn.fromMap(map),
      'dropColumn' => DropColumn.fromMap(map),
      'alterColumn' => AlterColumn.fromMap(map),
      'renameTable' => RenameTable.fromMap(map),
      'renameColumn' => RenameColumn.fromMap(map),
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
  const CreateTable({
    required this.tableName,
    required this.columns,
  });

  /// Creates a [CreateTable] from a map representation.
  factory CreateTable.fromMap(Map<String, dynamic> map) {
    return CreateTable(
      tableName: map['tableName'] as String,
      columns: (map['columns'] as List<dynamic>)
          .map((c) => ColumnInfo.fromMap(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The name of the table to create.
  final String tableName;

  /// The columns in the table.
  final List<ColumnInfo> columns;

  @override
  String describe() => 'Create table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'createTable',
      'tableName': tableName,
      'columns': columns.map((c) => c.toMap()).toList(),
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

/// {@template add_column}
/// Operation to add a column to a table.
/// {@endtemplate}
class AddColumn extends DiffOperation {
  /// {@macro add_column}
  const AddColumn(this.tableName, this.column);

  /// Creates an [AddColumn] from a map representation.
  factory AddColumn.fromMap(Map<String, dynamic> map) {
    return AddColumn(
      map['tableName'] as String,
      ColumnInfo.fromMap(map['column'] as Map<String, dynamic>),
    );
  }

  /// The name of the table.
  final String tableName;

  /// The column to add.
  final ColumnInfo column;

  @override
  String describe() => 'Add column "${column.name}" to table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'addColumn',
      'tableName': tableName,
      'column': column.toMap(),
    };
  }
}

/// {@template drop_column}
/// Operation to drop a column from a table.
/// {@endtemplate}
class DropColumn extends DiffOperation {
  /// {@macro drop_column}
  const DropColumn(this.tableName, this.columnName);

  /// Creates a [DropColumn] from a map representation.
  factory DropColumn.fromMap(Map<String, dynamic> map) {
    return DropColumn(
      map['tableName'] as String,
      map['columnName'] as String,
    );
  }

  /// The name of the table.
  final String tableName;

  /// The name of the column to drop.
  final String columnName;

  @override
  String describe() => 'Drop column "$columnName" from table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'dropColumn',
      'tableName': tableName,
      'columnName': columnName,
    };
  }
}

/// {@template alter_column}
/// Operation to alter a column.
/// {@endtemplate}
class AlterColumn extends DiffOperation {
  /// {@macro alter_column}
  const AlterColumn(this.tableName, this.oldColumn, this.newColumn);

  /// Creates an [AlterColumn] from a map representation.
  factory AlterColumn.fromMap(Map<String, dynamic> map) {
    return AlterColumn(
      map['tableName'] as String,
      ColumnInfo.fromMap(map['oldColumn'] as Map<String, dynamic>),
      ColumnInfo.fromMap(map['newColumn'] as Map<String, dynamic>),
    );
  }

  /// The name of the table.
  final String tableName;

  /// The column before alteration.
  final ColumnInfo oldColumn;

  /// The column after alteration.
  final ColumnInfo newColumn;

  @override
  String describe() => 'Alter column "${oldColumn.name}" in table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'alterColumn',
      'tableName': tableName,
      'oldColumn': oldColumn.toMap(),
      'newColumn': newColumn.toMap(),
    };
  }
}

/// {@template rename_table}
/// Operation to rename a table.
/// {@endtemplate}
class RenameTable extends DiffOperation {
  /// {@macro rename_table}
  const RenameTable(this.oldName, this.newName);

  /// Creates a [RenameTable] from a map representation.
  factory RenameTable.fromMap(Map<String, dynamic> map) {
    return RenameTable(
      map['oldName'] as String,
      map['newName'] as String,
    );
  }

  /// The current name of the table.
  final String oldName;

  /// The new name for the table.
  final String newName;

  @override
  String describe() => 'Rename table "$oldName" to "$newName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'renameTable',
      'oldName': oldName,
      'newName': newName,
    };
  }
}

/// {@template rename_column}
/// Operation to rename a column.
/// {@endtemplate}
class RenameColumn extends DiffOperation {
  /// {@macro rename_column}
  const RenameColumn(this.tableName, this.oldName, this.newName);

  /// Creates a [RenameColumn] from a map representation.
  factory RenameColumn.fromMap(Map<String, dynamic> map) {
    return RenameColumn(
      map['tableName'] as String,
      map['oldName'] as String,
      map['newName'] as String,
    );
  }

  /// The name of the table.
  final String tableName;

  /// The current name of the column.
  final String oldName;

  /// The new name for the column.
  final String newName;

  @override
  String describe() =>
      'Rename column "$oldName" to "$newName" in table "$tableName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'renameColumn',
      'tableName': tableName,
      'oldName': oldName,
      'newName': newName,
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
  String describe() =>
      'Create ${index.isUnique ? 'unique ' : ''}index "${index.name}" on table "${index.tableName}"';

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
  const DropIndex(this.indexName);

  /// Creates a [DropIndex] from a map representation.
  factory DropIndex.fromMap(Map<String, dynamic> map) {
    return DropIndex(map['indexName'] as String);
  }

  /// The name of the index to drop.
  final String indexName;

  @override
  String describe() => 'Drop index "$indexName"';

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'dropIndex',
      'indexName': indexName,
    };
  }
}
