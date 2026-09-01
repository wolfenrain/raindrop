import 'package:meta/meta.dart';
import 'package:raindrop/src/ddl/info_types.dart';

/// Validates that [data] holds exactly the keys the snapshot format
/// declares, returning it for further reading.
///
/// Any other key means the document was written by a different version of
/// the raindrop tooling. Silently ignoring it is how a renamed key becomes
/// a phantom schema change, so the parse fails instead, and a missing
/// [requiredKeys] entry fails for the same reason.
Map<String, dynamic> _checkKeys(
  Map<String, dynamic> data, {
  required String context,
  required Set<String> requiredKeys,
  Set<String> optionalKeys = const {},
}) {
  for (final key in data.keys) {
    if (!requiredKeys.contains(key) && !optionalKeys.contains(key)) {
      throw FormatException(
        'Unknown key "$key" in $context, was the file written by a '
        'different version of the raindrop tooling?',
      );
    }
  }
  for (final key in requiredKeys) {
    if (!data.containsKey(key)) {
      throw FormatException('Missing key "$key" in $context.');
    }
  }
  return data;
}

/// The schema of every table and index reachable from a set of schemas,
/// rendered for one dialect.
///
/// This describes the schema itself. It carries no identity and no format
/// version: those belong to whatever document embeds it, such as the CLI's
/// migration snapshots.
@immutable
class SchemaSnapshot {
  /// Creates a snapshot of a complete schema.
  const SchemaSnapshot({
    required this.dialect,
    required this.tables,
    this.indexes = const {},
  });

  /// Creates a schema snapshot from a map.
  factory SchemaSnapshot.fromMap(Map<String, dynamic> data) {
    _checkKeys(
      data,
      context: 'the schema',
      requiredKeys: const {'dialect', 'tables'},
      optionalKeys: const {'indexes'},
    );
    return SchemaSnapshot(
      dialect: data['dialect'] as String,
      tables: {
        for (final entry in (data['tables'] as Map<String, dynamic>).entries)
          entry.key: TableSnapshot.fromMap(
            entry.key,
            entry.value as Map<String, dynamic>,
          ),
      },
      indexes: {
        for (final entry
            in (data['indexes'] as Map<String, dynamic>? ?? {}).entries)
          entry.key: IndexSnapshot.fromMap(
            entry.key,
            entry.value as Map<String, dynamic>,
          ),
      },
    );
  }

  /// The SQL dialect this schema was rendered for, such as `sqlite`.
  final String dialect;

  /// Map of table name to table snapshot.
  final Map<String, TableSnapshot> tables;

  /// Map of index name to index snapshot.
  final Map<String, IndexSnapshot> indexes;

  /// The tables as the [TableInfo] the DDL generators consume.
  List<TableInfo> get tableInfos => [
        for (final table in tables.values) table.toTableInfo(),
      ];

  /// The indexes as the [IndexInfo] the DDL generators consume.
  List<IndexInfo> get indexInfos => [
        for (final index in indexes.values) index.toIndexInfo(),
      ];

  /// Converts the schema snapshot to a map.
  Map<String, dynamic> toMap() {
    return {
      'dialect': dialect,
      'tables': {
        for (final entry in tables.entries) entry.key: entry.value.toMap(),
      },
      'indexes': {
        for (final entry in indexes.entries) entry.key: entry.value.toMap(),
      },
    };
  }
}

/// Represents a snapshot of a single table.
class TableSnapshot {
  /// Creates a snapshot of a single table.
  const TableSnapshot({
    required this.name,
    required this.columns,
    this.checks = const {},
  });

  /// Creates a table snapshot from a map.
  factory TableSnapshot.fromMap(String name, Map<String, dynamic> data) {
    _checkKeys(
      data,
      context: 'table "$name"',
      requiredKeys: const {'name', 'columns'},
      optionalKeys: const {'checks'},
    );
    final columnsData = data['columns'] as Map<String, dynamic>;
    return TableSnapshot(
      name: name,
      columns: columnsData.map(
        (key, value) => MapEntry(
          key,
          ColumnSnapshot.fromMap(key, value as Map<String, dynamic>),
        ),
      ),
      // Materialize (not a lazy `.cast` view): these end up in DiffOperation
      // maps sent over an isolate SendPort, which rejects CastMap instances.
      checks: Map<String, String>.from(
        data['checks'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// The table name.
  final String name;

  /// Map of column name to column snapshot.
  final Map<String, ColumnSnapshot> columns;

  /// Map of constraint name to raw CHECK expression.
  final Map<String, String> checks;

  /// Converts the table snapshot to the [TableInfo] the DDL generators
  /// consume.
  TableInfo toTableInfo() {
    return TableInfo(
      name: name,
      columns: [for (final column in columns.values) column.toColumnInfo()],
      checks: checks,
    );
  }

  /// Converts the table snapshot to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'columns': columns.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      if (checks.isNotEmpty) 'checks': checks,
    };
  }
}

/// Represents foreign key reference information in a snapshot.
@immutable
class ForeignKeySnapshotRef {
  /// Creates a snapshot of a foreign key reference.
  const ForeignKeySnapshotRef({
    required this.referencedTable,
    required this.referencedColumn,
    this.onDelete,
    this.onUpdate,
  });

  /// Creates a foreign key reference from a map.
  factory ForeignKeySnapshotRef.fromMap(Map<String, dynamic> data) {
    _checkKeys(
      data,
      context: 'a foreign key reference',
      requiredKeys: const {'referencedTable', 'referencedColumn'},
      optionalKeys: const {'onDelete', 'onUpdate'},
    );
    return ForeignKeySnapshotRef(
      referencedTable: data['referencedTable'] as String,
      referencedColumn: data['referencedColumn'] as String,
      onDelete: data['onDelete'] as String?,
      onUpdate: data['onUpdate'] as String?,
    );
  }

  /// The name of the referenced table.
  final String referencedTable;

  /// The name of the referenced column.
  final String referencedColumn;

  /// The ON DELETE action ('CASCADE', 'SET NULL').
  final String? onDelete;

  /// The ON UPDATE action ('CASCADE', 'SET NULL').
  final String? onUpdate;

  /// Converts the reference to the [ForeignKeyInfo] the DDL generators
  /// consume.
  ForeignKeyInfo toForeignKeyInfo() {
    return ForeignKeyInfo(
      referencedTable: referencedTable,
      referencedColumn: referencedColumn,
      onDelete: onDelete,
      onUpdate: onUpdate,
    );
  }

  /// Converts the foreign key reference to a map.
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
    return other is ForeignKeySnapshotRef &&
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

/// Represents a snapshot of a single column.
@immutable
class ColumnSnapshot {
  /// Creates a snapshot of a single column.
  const ColumnSnapshot({
    required this.name,
    required this.type,
    required this.isNullable,
    this.primaryKey = false,
    this.autoIncrement = false,
    this.defaultValue,
    this.foreignKey,
  });

  /// Creates a column snapshot from a map.
  ///
  /// The default is read from `default`, which is what the snapshot format
  /// calls it; [ColumnInfo] calls the same thing `defaultValue`.
  factory ColumnSnapshot.fromMap(String name, Map<String, dynamic> data) {
    _checkKeys(
      data,
      context: 'column "$name"',
      requiredKeys: const {'name', 'type', 'primaryKey', 'isNullable'},
      optionalKeys: const {'autoIncrement', 'default', 'foreignKey'},
    );
    return ColumnSnapshot(
      name: name,
      type: data['type'] as String,
      isNullable: data['isNullable'] as bool,
      primaryKey: data['primaryKey'] as bool,
      autoIncrement: data['autoIncrement'] as bool? ?? false,
      defaultValue: data['default'] as String?,
      foreignKey: switch (data['foreignKey']) {
        final Map<String, dynamic> data => ForeignKeySnapshotRef.fromMap(data),
        _ => null,
      },
    );
  }

  /// The column name.
  final String name;

  /// The SQL type ('INTEGER', 'TEXT', 'TIMESTAMP').
  final String type;

  /// Whether the column is nullable.
  final bool isNullable;

  /// Whether this is a primary key column.
  final bool primaryKey;

  /// Whether this column auto-increments.
  final bool autoIncrement;

  /// The default value expression.
  final String? defaultValue;

  /// Foreign key reference information.
  final ForeignKeySnapshotRef? foreignKey;

  /// Converts the column snapshot to the [ColumnInfo] the DDL generators
  /// consume.
  ColumnInfo toColumnInfo() {
    return ColumnInfo(
      name: name,
      type: type,
      isNullable: isNullable,
      primaryKey: primaryKey,
      autoIncrement: autoIncrement,
      defaultValue: defaultValue,
      foreignKey: foreignKey?.toForeignKeyInfo(),
    );
  }

  /// Converts the column snapshot to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'primaryKey': primaryKey,
      'isNullable': isNullable,
      if (autoIncrement) 'autoIncrement': autoIncrement,
      if (defaultValue != null) 'default': defaultValue,
      if (foreignKey != null) 'foreignKey': foreignKey!.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColumnSnapshot &&
        other.name == name &&
        other.type == type &&
        other.isNullable == isNullable &&
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
      isNullable,
      primaryKey,
      autoIncrement,
      defaultValue,
      foreignKey,
    );
  }
}

/// Represents an index snapshot.
@immutable
class IndexSnapshot {
  /// Creates a snapshot of a single index.
  const IndexSnapshot({
    required this.name,
    required this.tableName,
    required this.columns,
    this.isUnique = false,
    this.where,
  });

  /// Creates an index snapshot from a map.
  factory IndexSnapshot.fromMap(String name, Map<String, dynamic> data) {
    _checkKeys(
      data,
      context: 'index "$name"',
      requiredKeys: const {'name', 'tableName', 'columns', 'isUnique'},
      optionalKeys: const {'where'},
    );
    return IndexSnapshot(
      name: name,
      tableName: data['tableName'] as String,
      // Materialize (not a lazy `.cast` view): these end up in DiffOperation
      // maps sent over an isolate SendPort, which rejects CastList instances.
      columns: List<String>.from(data['columns'] as List<dynamic>),
      isUnique: data['isUnique'] as bool? ?? false,
      where: data['where'] as String?,
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

  /// Optional partial-index predicate (raw SQL).
  final String? where;

  /// Converts the index snapshot to the [IndexInfo] the DDL generators
  /// consume.
  IndexInfo toIndexInfo() {
    return IndexInfo(
      name: name,
      tableName: tableName,
      columns: columns,
      isUnique: isUnique,
      where: where,
    );
  }

  /// Converts the index snapshot to a map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tableName': tableName,
      'columns': columns,
      'isUnique': isUnique,
      if (where != null) 'where': where,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IndexSnapshot) return false;
    if (other.name != name) return false;
    if (other.tableName != tableName) return false;
    if (other.isUnique != isUnique) return false;
    if (other.where != where) return false;
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
      where,
    );
  }
}
