import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/entrypoint_runner.dart';

/// A table declaration, as a name the generated entrypoint can reference.
class LocatedSchema {
  /// Creates a [LocatedSchema].
  const LocatedSchema({required this.filePath, required this.variableName});

  /// Absolute path of the file declaring it.
  final String filePath;

  /// The top-level variable's Dart name.
  final String variableName;
}

/// Finds the schemas a project declares, so they can be referenced by name.
class SchemaLocator {
  /// Every schema declared under [directoryPath], in a stable order.
  Future<List<LocatedSchema>> locate(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) return const [];

    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => p.absolute(file.path))
        .toList()
      // Sorted so the generated entrypoint, and therefore table order in the
      // snapshot, does not depend on the filesystem.
      ..sort();
    if (dartFiles.isEmpty) return const [];

    // The analyzer resolves types properly, but it has to read the Dart
    // SDK off disk to do it, and an AOT-compiled CLI has no SDK to point
    // at -- AnalysisContextCollection throws while loading
    // allowed_experiments.json. So when this process is not the Dart VM,
    // fall back to reading the declarations out of the source.
    if (!EntrypointRunner.isDartVm) {
      return locateWithoutAnalyzer(dartFiles);
    }

    final collection = AnalysisContextCollection(
      includedPaths: [p.absolute(directoryPath)],
    );

    final located = <LocatedSchema>[];
    for (final filePath in dartFiles) {
      final context = collection.contextFor(filePath);
      final resolved = await context.currentSession.getResolvedUnit(filePath);
      if (resolved is! ResolvedUnitResult) continue;

      for (final declaration in resolved.unit.declarations) {
        if (declaration is! TopLevelVariableDeclaration) continue;
        for (final variable in declaration.variables.variables) {
          final type = declaration.variables.type?.type ??
              variable.initializer?.staticType;
          if (type == null || !_isSchema(type)) continue;
          located.add(
            LocatedSchema(
              filePath: filePath,
              variableName: variable.name.lexeme,
            ),
          );
        }
      }
    }
    return located;
  }

  /// Every table declaration in [dartFiles], read straight from the source.
  ///
  /// Used only when the analyzer is unavailable (see [locate]). Matches the
  /// declaration form every table uses -- `final <name> = <driver>Table(...)`
  /// -- rather than every top-level variable, because each name found here is
  /// emitted into the generated entrypoint and a non-table would not compile.
  @visibleForTesting
  List<LocatedSchema> locateWithoutAnalyzer(List<String> dartFiles) {
    final declaration = RegExp(
      r'^\s*(?:final|const)\s+(?:\w[\w<>,\s]*\s+)?(\w+)\s*=\s*\w*[Tt]able\s*\(',
      multiLine: true,
    );

    final located = <LocatedSchema>[];
    for (final filePath in dartFiles) {
      final content = File(filePath).readAsStringSync();
      for (final match in declaration.allMatches(content)) {
        final name = match.group(1);
        if (name == null || name.isEmpty) continue;
        located.add(
          LocatedSchema(filePath: filePath, variableName: name),
        );
      }
    }
    return located;
  }

  /// Whether [type] is a `Schema` from `package:raindrop`.
  bool _isSchema(DartType type) {
    if (type is! InterfaceType) return false;
    for (final candidate in [type, ...type.allSupertypes]) {
      final element = candidate.element;
      if (element.name != 'Schema') continue;
      // Qualified by library, so a project's own class called `Schema` is not
      // mistaken for a table.
      if (element.library.identifier.startsWith('package:raindrop/')) {
        return true;
      }
    }
    return false;
  }
}
