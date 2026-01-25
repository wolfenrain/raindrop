/// {@template foreign_key_info}
/// Foreign key information for DDL generation.
///
/// This is a simple data class that holds the information needed to generate
/// foreign key constraints in DDL statements.
/// {@endtemplate}
class ForeignKeyInfo {
  /// {@macro foreign_key_info}
  const ForeignKeyInfo({
    required this.referencedTable,
    required this.referencedColumn,
    this.onDelete,
    this.onUpdate,
  });

  /// Creates a [ForeignKeyInfo] from a map representation.
  factory ForeignKeyInfo.fromMap(Map<String, dynamic> map) {
    return ForeignKeyInfo(
      referencedTable: map['referencedTable'] as String,
      referencedColumn: map['referencedColumn'] as String,
      onDelete: map['onDelete'] as String?,
      onUpdate: map['onUpdate'] as String?,
    );
  }

  /// The name of the referenced table.
  final String referencedTable;

  /// The name of the referenced column.
  final String referencedColumn;

  /// The ON DELETE action (e.g., 'CASCADE', 'SET NULL').
  final String? onDelete;

  /// The ON UPDATE action (e.g., 'CASCADE', 'SET NULL').
  final String? onUpdate;

  /// Converts this foreign key info to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'referencedTable': referencedTable,
      'referencedColumn': referencedColumn,
      if (onDelete != null) 'onDelete': onDelete,
      if (onUpdate != null) 'onUpdate': onUpdate,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForeignKeyInfo &&
        other.referencedTable == referencedTable &&
        other.referencedColumn == referencedColumn &&
        other.onDelete == onDelete &&
        other.onUpdate == onUpdate;
  }

  @override
  int get hashCode {
    return Object.hash(
      referencedTable,
      referencedColumn,
      onDelete,
      onUpdate,
    );
  }
}

/// {@template column_info}
/// Column information for DDL generation.
///
/// This is a simple data class that holds the information needed to generate
/// DDL statements, decoupled from the CLI's snapshot types.
/// {@endtemplate}
class ColumnInfo {
  /// {@macro column_info}
  const ColumnInfo({
    required this.name,
    required this.type,
    required this.nullable,
    this.primaryKey = false,
    this.autoIncrement = false,
    this.defaultValue,
    this.foreignKey,
  });

  /// Creates a [ColumnInfo] from a map representation.
  factory ColumnInfo.fromMap(Map<String, dynamic> map) {
    return ColumnInfo(
      name: map['name'] as String,
      type: map['type'] as String,
      nullable: map['nullable'] as bool,
      primaryKey: map['primaryKey'] as bool? ?? false,
      autoIncrement: map['autoIncrement'] as bool? ?? false,
      defaultValue: map['defaultValue'] as String?,
      foreignKey: map['foreignKey'] != null
          ? ForeignKeyInfo.fromMap(map['foreignKey'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The column name.
  final String name;

  /// The SQL type (e.g., 'INTEGER', 'TEXT', 'TIMESTAMP').
  final String type;

  /// Whether the column is nullable.
  final bool nullable;

  /// Whether this is a primary key column.
  final bool primaryKey;

  /// Whether this column auto-increments.
  final bool autoIncrement;

  /// The default value expression.
  final String? defaultValue;

  /// Foreign key constraint information.
  final ForeignKeyInfo? foreignKey;

  /// Converts this column info to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'nullable': nullable,
      'primaryKey': primaryKey,
      'autoIncrement': autoIncrement,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (foreignKey != null) 'foreignKey': foreignKey!.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColumnInfo &&
        other.name == name &&
        other.type == type &&
        other.nullable == nullable &&
        other.primaryKey == primaryKey &&
        other.autoIncrement == autoIncrement &&
        other.defaultValue == defaultValue &&
        other.foreignKey == foreignKey;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      type,
      nullable,
      primaryKey,
      autoIncrement,
      defaultValue,
      foreignKey,
    );
  }
}

/// {@template table_info}
/// Table information for DDL generation.
/// {@endtemplate}
class TableInfo {
  /// {@macro table_info}
  const TableInfo({
    required this.name,
    required this.columns,
  });

  /// Creates a [TableInfo] from a map representation.
  factory TableInfo.fromMap(Map<String, dynamic> map) {
    return TableInfo(
      name: map['name'] as String,
      columns: (map['columns'] as List<dynamic>)
          .map((c) => ColumnInfo.fromMap(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The table name.
  final String name;

  /// The columns in the table.
  final List<ColumnInfo> columns;

  /// Converts this table info to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'columns': columns.map((c) => c.toMap()).toList(),
    };
  }
}

/// {@template index_info}
/// Index information for DDL generation.
///
/// This is a simple data class that holds the information needed to generate
/// DDL statements for index operations.
/// {@endtemplate}
class IndexInfo {
  /// {@macro index_info}
  const IndexInfo({
    required this.name,
    required this.tableName,
    required this.columns,
    this.isUnique = false,
  });

  /// Creates an [IndexInfo] from a map representation.
  factory IndexInfo.fromMap(Map<String, dynamic> map) {
    return IndexInfo(
      name: map['name'] as String,
      tableName: map['tableName'] as String,
      columns: (map['columns'] as List<dynamic>).cast<String>(),
      isUnique: map['isUnique'] as bool? ?? false,
    );
  }

  /// The index name.
  final String name;

  /// The table this index belongs to.
  final String tableName;

  /// The column names that make up the index.
  final List<String> columns;

  /// Whether this index enforces uniqueness.
  final bool isUnique;

  /// Converts this index info to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tableName': tableName,
      'columns': columns,
      'isUnique': isUnique,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IndexInfo) return false;
    if (other.name != name) return false;
    if (other.tableName != tableName) return false;
    if (other.isUnique != isUnique) return false;
    if (other.columns.length != columns.length) return false;
    for (var i = 0; i < columns.length; i++) {
      if (other.columns[i] != columns[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      tableName,
      Object.hashAll(columns),
      isUnique,
    );
  }
}
