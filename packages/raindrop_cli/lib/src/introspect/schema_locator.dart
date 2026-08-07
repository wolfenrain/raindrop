import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;

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

  /// Whether [type] is a `Schema` from `package:raindrop`.
  bool _isSchema(DartType type) {
    if (type is! InterfaceType) return false;
    for (final candidate in [type, ...type.allSupertypes]) {
      // The old element model, deprecated but stable.
      // ignore: deprecated_member_use
      final element = candidate.element;
      if (element.name != 'Schema') continue;
      // Qualified by library, so a project's own class called `Schema` is not
      // mistaken for a table.
      // ignore: deprecated_member_use
      if (element.library.identifier.startsWith('package:raindrop/')) {
        return true;
      }
    }
    return false;
  }
}
