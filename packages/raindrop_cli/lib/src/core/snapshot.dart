import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:raindrop_cli/src/core/format.dart';

/// Represents a snapshot of the database schema at a point in time.
///
/// Stores the complete schema state with unique IDs for tracking lineage.
class SchemaSnapshot {
  /// Creates a snapshot of the complete schema state.
  const SchemaSnapshot({
    required this.version,
    required this.dialect,
    required this.id,
    required this.prevId,
    required this.tables,
    this.indexes = const {},
  });

  /// Creates a snapshot from JSON string.
  factory SchemaSnapshot.fromJson(String json) {
    final data = checkKeys(
      jsonDecode(json) as Map<String, dynamic>,
      context: 'the snapshot',
      requiredKeys: const {'version', 'dialect', 'id', 'prevId', 'tables'},
      optionalKeys: const {'indexes'},
    );
    final version = data['version'] as String;
    if (version != currentVersion) {
      throw FormatException(
        'Snapshot version "$version" is not the supported "$currentVersion".',
      );
    }
    return SchemaSnapshot(
      version: version,
      dialect: data['dialect'] as String,
      id: data['id'] as String,
      prevId: data['prevId'] as String,
      tables: {
        for (final entry in (data['tables'] as Map<String, dynamic>).entries)
          entry.key: TableSnapshot.fromMap(
            entry.key,
            entry.value as Map<String, dynamic>,
          )
      },
      indexes: {
        for (final entry
            in (data['indexes'] as Map<String, dynamic>? ?? {}).entries)
          entry.key: IndexSnapshot.fromMap(
            entry.key,
            entry.value as Map<String, dynamic>,
          )
      },
    );
  }

  /// The current snapshot format version.
  static const currentVersion = '1';

  /// Null UUID used for the first snapshot's prevId.
  static const nullUuid = '00000000-0000-0000-0000-000000000000';

  /// The snapshot format version.
  final String version;

  /// The SQL dialect (e.g., 'postgres', 'sqlite').
  final String dialect;

  /// Unique identifier for this snapshot.
  final String id;

  /// ID of the previous snapshot (null UUID for the first snapshot).
  final String prevId;

  /// Map of table name to table snapshot.
  final Map<String, TableSnapshot> tables;

  /// Map of index name to index definition.
  final Map<String, IndexSnapshot> indexes;

  /// Generates a random UUID v4.
  static String generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '''
${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}''';
  }

  /// Loads a snapshot from a file.
  static Future<SchemaSnapshot?> load(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    final content = await file.readAsString();
    return SchemaSnapshot.fromJson(content);
  }

  /// Converts the snapshot to JSON string.
  String toJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'version': version,
      'dialect': dialect,
      'id': id,
      'prevId': prevId,
      'tables': {
        for (final entry in tables.entries) entry.key: entry.value.toMap(),
      },
      'indexes': {
        for (final entry in indexes.entries) entry.key: entry.value.toMap(),
      },
    });
  }

  /// Saves the snapshot to a file.
  Future<void> save(String path) async {
    final file = File(path);
    final dir = Directory(file.parent.path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await file.writeAsString(toJson());
  }

  /// Creates a copy with the given id and prevId.
  SchemaSnapshot copyWith({
    String? id,
    String? prevId,
  }) {
    return SchemaSnapshot(
      version: version,
      dialect: dialect,
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      tables: tables,
      indexes: indexes,
    );
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
    checkKeys(
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
    checkKeys(
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

  /// The ON DELETE action (e.g., 'CASCADE', 'SET NULL').
  final String? onDelete;

  /// The ON UPDATE action (e.g., 'CASCADE', 'SET NULL').
  final String? onUpdate;

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
  factory ColumnSnapshot.fromMap(String name, Map<String, dynamic> data) {
    checkKeys(
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

  /// The SQL type (e.g., 'INTEGER', 'TEXT', 'TIMESTAMP').
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
    checkKeys(
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
