import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:raindrop_cli/src/parser/column_extractor.dart';
import 'package:raindrop_cli/src/parser/table_visitor.dart';

/// Parser for Raindrop schema files using Dart AST analysis.
class SchemaParser {
  /// Parses all schema files in a directory and returns a schema snapshot.
  ///
  /// The [dialect] parameter specifies which SQL dialect to use for filtering
  /// table definitions. Only tables matching this dialect will be included.
  ///
  /// The returned snapshot will have a new unique ID and the prevId set to
  /// the null UUID. The caller should update prevId based on the journal
  /// when saving the snapshot.
  Future<SchemaSnapshot> parseDirectory(
    String path, {
    required String dialect,
    String? prevId,
  }) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: dialect,
        id: SchemaSnapshot.generateId(),
        prevId: prevId ?? SchemaSnapshot.nullUuid,
        tables: const {},
      );
    }

    final dartFiles = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => p.absolute(f.path))
        .toList();

    if (dartFiles.isEmpty) {
      return SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: dialect,
        id: SchemaSnapshot.generateId(),
        prevId: prevId ?? SchemaSnapshot.nullUuid,
        tables: const {},
      );
    }

    final tables = <String, TableSnapshot>{};
    final indexes = <String, IndexSnapshot>{};

    // Create an analysis context for the directory
    final collection = AnalysisContextCollection(
      includedPaths: [p.absolute(path)],
    );

    for (final filePath in dartFiles) {
      final context = collection.contextFor(filePath);
      final result = await context.currentSession.getResolvedUnit(filePath);

      if (result is! ResolvedUnitResult) {
        continue;
      }

      // Visit the AST to find table definitions matching the dialect
      final visitor = TableDefinitionVisitor(expectedDialect: dialect);
      result.unit.accept(visitor);

      // Extract column definitions for all schema types in this file
      final extractor = ColumnExtractor();
      result.unit.accept(extractor);

      // Process found table definitions
      for (final tableDef in visitor.tableDefinitions) {
        // Extract columns from the schema class
        final columns = _extractColumnsFromExtractor(extractor, tableDef);

        if (columns.isNotEmpty) {
          tables[tableDef.tableName] = TableSnapshot(
            name: tableDef.tableName,
            columns: columns,
          );

          // Extract indexes for this table
          final tableIndexes = _extractIndexes(tableDef, columns);
          for (final index in tableIndexes) {
            indexes[index.name] = index;
          }
        }
      }
    }

    return SchemaSnapshot(
      version: SchemaSnapshot.currentVersion,
      dialect: dialect,
      id: SchemaSnapshot.generateId(),
      prevId: prevId ?? SchemaSnapshot.nullUuid,
      tables: tables,
      indexes: indexes,
    );
  }

  /// Extracts column definitions from a pre-populated column extractor.
  Map<String, ColumnSnapshot> _extractColumnsFromExtractor(
    ColumnExtractor extractor,
    TableDefinition tableDef,
  ) {
    // Try to find columns for this table's schema type
    final schemaType = tableDef.schemaType;
    if (schemaType != null && extractor.schemaColumns.containsKey(schemaType)) {
      return extractor.schemaColumns[schemaType]!;
    }

    return {};
  }

  /// Extracts index snapshots from a table definition.
  ///
  /// Maps Dart field names to SQL column names using the column map.
  List<IndexSnapshot> _extractIndexes(
    TableDefinition tableDef,
    Map<String, ColumnSnapshot> columns,
  ) {
    final result = <IndexSnapshot>[];

    // Build a map from Dart field name to SQL column name
    // The column key in the map IS the SQL column name
    // We need to find the field name -> column name mapping
    // For now, we'll assume the field names match common conventions
    // TODO: Improve field name to column name mapping
    final fieldToColumn = <String, String>{};
    for (final entry in columns.entries) {
      // The entry key is the SQL column name
      // Try to match by converting snake_case to camelCase
      final sqlName = entry.key;
      final camelCase = _snakeToCamel(sqlName);
      fieldToColumn[camelCase] = sqlName;
      // Also add direct mapping for exact matches
      fieldToColumn[sqlName] = sqlName;
    }

    for (final indexDef in tableDef.indexes) {
      // Map field names to SQL column names
      final sqlColumns = <String>[];
      for (final field in indexDef.columnFields) {
        final sqlName = fieldToColumn[field];
        if (sqlName != null) {
          sqlColumns.add(sqlName);
        } else {
          // Fall back to snake_case conversion
          sqlColumns.add(_camelToSnake(field));
        }
      }

      if (sqlColumns.isNotEmpty) {
        result.add(IndexSnapshot(
          name: indexDef.name,
          tableName: tableDef.tableName,
          columns: sqlColumns,
          isUnique: indexDef.isUnique,
          where: indexDef.where,
        ));
      }
    }

    return result;
  }

  /// Converts snake_case to camelCase.
  String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    if (parts.isEmpty) return snake;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
  }

  /// Converts camelCase to snake_case.
  String _camelToSnake(String camel) {
    return camel.replaceAllMapped(
      RegExp('([A-Z])'),
      (m) => '_${m.group(1)!.toLowerCase()}',
    );
  }
}

/// Represents a table definition found in the AST.
class TableDefinition {
  const TableDefinition({
    required this.functionName,
    required this.tableName,
    this.schemaType,
    this.indexes = const [],
  });

  /// The function used to create the table (e.g., 'postgresTable', 'sqliteTable').
  final String functionName;

  /// The SQL table name.
  final String tableName;

  /// The Dart schema type name.
  final String? schemaType;

  /// Index definitions found in the table declaration.
  final List<IndexDefinition> indexes;
}

/// Represents an index definition found in the AST.
class IndexDefinition {
  const IndexDefinition({
    required this.name,
    required this.columnFields,
    this.isUnique = false,
    this.where,
  });

  /// The name of the index.
  final String name;

  /// The Dart field names of columns in the index.
  ///
  /// These need to be mapped to SQL column names during parsing.
  final List<String> columnFields;

  /// Whether this index is unique.
  final bool isUnique;

  /// Optional partial-index predicate (raw SQL), if `where:` was passed.
  final String? where;
}
