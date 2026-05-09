import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:raindrop_cli/src/runtime/schema_table_discovery.dart';

/// Loads a [SchemaSnapshot] by running the app package: table metadata comes
/// from live [Table] instances (see `Table.get`), not from the static analyzer.
class RuntimeSchemaLoader {
  const RuntimeSchemaLoader._();

  /// Prefer the current VM when it is `dart`; otherwise rely on `dart` on PATH.
  static String _dartExecutable() {
    final resolved = Platform.resolvedExecutable;
    final name = p.basename(resolved).toLowerCase();
    if (name == 'dart' || name == 'dart.exe') {
      return resolved;
    }
    return 'dart';
  }

  /// Writes `.dart_tool/raindrop/schema_snapshot_runner.dart` under
  /// [projectRoot], runs it with the Dart VM, and decodes JSON into a snapshot.
  static Future<SchemaSnapshot> load({
    required String projectRoot,
    required String schemaPath,
    required String dialect,
    required String? prevId,
  }) async {
    final normalizedProject = p.normalize(p.absolute(projectRoot));
    final normalizedSchema = p.normalize(p.absolute(schemaPath));

    final variables = await discoverSchemaVariables(
      schemaDir: normalizedSchema,
      packageRoot: normalizedProject,
    );
    if (variables.isEmpty) {
      return SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: dialect,
        id: SchemaSnapshot.generateId(),
        prevId: prevId ?? SchemaSnapshot.nullUuid,
        tables: const {},
        indexes: const {},
      );
    }

    final packageName = _readPackageName(normalizedProject);
    final runnerDir =
        Directory(p.join(normalizedProject, '.dart_tool', 'raindrop'));
    if (!runnerDir.existsSync()) {
      runnerDir.createSync(recursive: true);
    }
    final runnerPath =
        p.join(runnerDir.path, 'schema_snapshot_runner.dart');
    final source = _emitRunner(
      packageName: packageName,
      normalizedProject: normalizedProject,
      variables: variables,
      dialect: dialect,
    );
    File(runnerPath).writeAsStringSync(source);

    final result = await Process.run(
      _dartExecutable(),
      [runnerPath],
      workingDirectory: normalizedProject,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    if (result.exitCode != 0) {
      throw StateError(
        'Raindrop schema introspection failed (exit ${result.exitCode}).\n'
        '${result.stderr}',
      );
    }

    final decoded = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final tablesRaw = decoded['tables'] as Map<String, dynamic>? ?? {};
    final indexesRaw = decoded['indexes'] as Map<String, dynamic>? ?? {};

    final tables = <String, TableSnapshot>{
      for (final e in tablesRaw.entries)
        e.key: TableSnapshot.fromMap(e.key, e.value as Map<String, dynamic>),
    };

    final indexes = <String, IndexSnapshot>{
      for (final e in indexesRaw.entries)
        e.key: IndexSnapshot.fromMap(e.key, e.value as Map<String, dynamic>),
    };

    return SchemaSnapshot(
      version: SchemaSnapshot.currentVersion,
      dialect: dialect,
      id: SchemaSnapshot.generateId(),
      prevId: prevId ?? SchemaSnapshot.nullUuid,
      tables: tables,
      indexes: indexes,
    );
  }

  static String _readPackageName(String projectRoot) {
    final pubspec = File(p.join(projectRoot, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw StateError('No pubspec.yaml in project root: $projectRoot');
    }
    final map = loadYaml(pubspec.readAsStringSync());
    if (map is! YamlMap) {
      throw StateError('Invalid pubspec.yaml: $projectRoot');
    }
    final name = map['name'] as String?;
    if (name == null || name.isEmpty) {
      throw StateError('pubspec name missing: $projectRoot');
    }
    return name;
  }

  static String _emitRunner({
    required String packageName,
    required String normalizedProject,
    required List<DiscoveredSchemaVariable> variables,
    required String dialect,
  }) {
    final libRoot = p.normalize(p.absolute(p.join(normalizedProject, 'lib')));
    final byFile = <String, List<String>>{};
    for (final v in variables) {
      byFile.putIfAbsent(p.normalize(p.absolute(v.filePath)), () => []).add(v.variableName);
    }
    for (final entry in byFile.entries) {
      entry.value.sort();
    }
    final sortedFiles = byFile.keys.toList()..sort();

    final imports = StringBuffer();
    final schemaExpressions = StringBuffer();
    var i = 0;
    for (final file in sortedFiles) {
      if (!p.isWithin(libRoot, file)) {
        throw StateError(
          'Raindrop runtime schema loading requires schema files under '
          '`lib/`. Offending file: $file',
        );
      }
      final rel = p.relative(file, from: libRoot);
      final posixRel = rel.split(p.separator).join('/');
      final importUri = 'package:$packageName/$posixRel';

      final prefix = 'r${i++}';
      imports.writeln("import '$importUri' as $prefix;");
      for (final name in byFile[file]!) {
        schemaExpressions.writeln('    $prefix.$name,');
      }
    }

    final dialectLiteral = jsonEncode(dialect);

    return '''
// Generated by raindrop_cli. Do not edit.
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:raindrop/raindrop.dart';

$imports
String? _referentialSql(ReferentialAction? a) {
  if (a == null) return null;
  return switch (a) {
    ReferentialAction.cascade => 'CASCADE',
    ReferentialAction.setNull => 'SET NULL',
    ReferentialAction.setDefault => 'SET DEFAULT',
    ReferentialAction.restrict => 'RESTRICT',
    ReferentialAction.noAction => 'NO ACTION',
  };
}

void main() {
  const expectedDialect = $dialectLiteral;
  final schemaValues = <Object?>[
$schemaExpressions
  ];

  final tables = <String, Map<String, dynamic>>{};
  final indexes = <String, Map<String, dynamic>>{};

  for (final raw in schemaValues) {
    final table = Table.get(raw as dynamic)!;
    if (table.dialect != null && table.dialect != expectedDialect) {
      continue;
    }

    final columns = <String, Map<String, dynamic>>{};
    for (final col in table.columns) {
      final sqlType = col.sqlType;
      if (sqlType == null || sqlType.isEmpty) {
        throw StateError(
          'Column "\${col.name}" on "\${table.name}" has no sqlType',
        );
      }
      final fk = col.foreignKeyReference;
      columns[col.name] = {
        'name': col.name,
        'type': sqlType,
        'primaryKey': col.isPrimaryKey,
        'isNullable': col.isNullable,
        if (col.autoIncrement) 'autoincrement': true,
        if (col.defaultValue != null) 'default': col.defaultValue,
        if (fk != null)
          'foreignKey': {
            'referencedTable': fk.referencedTable,
            'referencedColumn': fk.referencedColumnName,
            if (_referentialSql(fk.onDelete) case final d?) 'onDelete': d,
            if (_referentialSql(fk.onUpdate) case final u?) 'onUpdate': u,
          },
      };
    }

    final sortedColumns = Map<String, Map<String, dynamic>>.fromEntries(
      columns.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    tables[table.name] = {
      'name': table.name,
      'columns': sortedColumns,
    };

    for (final idx in table.indexes) {
      indexes[idx.name] = {
        'name': idx.name,
        'tableName': table.name,
        'columns': [for (final c in idx.columns) c.name],
        'isUnique': idx.isUnique,
      };
    }
  }

  final sortedTables = Map<String, dynamic>.fromEntries(
    tables.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
  final sortedIndexes = Map<String, dynamic>.fromEntries(
    indexes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );

  print(jsonEncode({
    'tables': sortedTables,
    'indexes': sortedIndexes,
  }));
}
''';
  }
}
