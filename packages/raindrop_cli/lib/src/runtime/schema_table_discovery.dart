import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;

/// A top-level variable whose static type is a Raindrop [Schema] subtype.
class DiscoveredSchemaVariable {
  const DiscoveredSchemaVariable({
    required this.filePath,
    required this.variableName,
  });

  final String filePath;
  final String variableName;
}

/// Finds top-level `final x = …` declarations whose initializer has a static
/// type that extends or implements **`Schema` from package:raindrop**.
///
/// This includes indirection such as `myTables.users` where `myTables()` or a
/// field returns a schema instance, and custom wrappers, as long as the
/// expression is typed as a concrete `Schema` subtype.
///
/// [packageRoot] must be the root of the Dart package (directory containing
/// `pubspec.yaml`) so imports and `package:raindrop` resolve correctly.
/// [schemaDir] limits which files are scanned (typically `lib/.../schemas`).
bool _isDartVmHost() {
  final name = p.basename(Platform.resolvedExecutable).toLowerCase();
  return name == 'dart' || name == 'dart.exe';
}

Future<List<DiscoveredSchemaVariable>> discoverSchemaVariables({
  required String schemaDir,
  required String packageRoot,
}) async {
  final dartFiles = _discoverDartFiles(schemaDir);
  if (dartFiles.isEmpty) {
    return const [];
  }

  if (!_isDartVmHost()) {
    return _discoverSchemaVariablesWithoutAnalyzer(dartFiles);
  }

  final absRoot = p.normalize(p.absolute(packageRoot));
  final absSchemaRoot = p.normalize(p.absolute(schemaDir));
  final includedPaths = {absRoot, absSchemaRoot}.toList();
  final collection = AnalysisContextCollection(includedPaths: includedPaths);
  final out = <DiscoveredSchemaVariable>[];

  for (final path in dartFiles) {
    final context = collection.contextFor(path);
    final result = await context.currentSession.getResolvedUnit(path);
    if (result is! ResolvedUnitResult) {
      continue;
    }

    for (final decl in result.unit.declarations) {
      if (decl is! TopLevelVariableDeclaration) {
        continue;
      }
      for (final variable in decl.variables.variables) {
        final init = variable.initializer;
        if (init == null) {
          continue;
        }
        final staticType = init.staticType;
        if (!_isRaindropSchemaInstanceType(staticType)) {
          continue;
        }
        out.add(DiscoveredSchemaVariable(
          filePath: path,
          variableName: variable.name.lexeme,
        ));
      }
    }
  }

  out.sort((a, b) {
    final c = a.filePath.compareTo(b.filePath);
    if (c != 0) {
      return c;
    }
    return a.variableName.compareTo(b.variableName);
  });

  return out;
}

/// Regex-based discovery for compiled hosts where the analyzer cannot load a
/// Dart SDK (see `FolderBasedDartSdk` / `allowed_experiments.json` failures).
///
/// The runtime introspection runner skips values that are not Raindrop schemas.
List<DiscoveredSchemaVariable> _discoverSchemaVariablesWithoutAnalyzer(
  List<String> dartFiles,
) {
  final declarationPattern = RegExp(
    r'^\s*(?:final|const|var)\s+(\w+)\s*=',
    multiLine: true,
  );
  final out = <DiscoveredSchemaVariable>[];

  for (final path in dartFiles) {
    final content = File(path).readAsStringSync();
    for (final match in declarationPattern.allMatches(content)) {
      final name = match.group(1);
      if (name == null || name.isEmpty) {
        continue;
      }
      out.add(DiscoveredSchemaVariable(
        filePath: path,
        variableName: name,
      ));
    }
  }

  out.sort((a, b) {
    final c = a.filePath.compareTo(b.filePath);
    if (c != 0) {
      return c;
    }
    return a.variableName.compareTo(b.variableName);
  });

  return out;
}

bool _isRaindropSchemaInstanceType(DartType? type) {
  if (type == null) {
    return false;
  }
  final erased = type.extensionTypeErasure;
  if (erased is InterfaceType) {
    return _extendsOrImplementsRaindropSchema(erased);
  }
  if (erased is TypeParameterType) {
    final bound = erased.bound;
    if (bound is InterfaceType) {
      return _extendsOrImplementsRaindropSchema(bound);
    }
  }
  return false;
}

bool _extendsOrImplementsRaindropSchema(InterfaceType type) {
  for (final sup in type.allSupertypes) {
    if (_isRaindropSchemaElement(sup.element3)) {
      return true;
    }
  }
  return false;
}

bool _isRaindropSchemaElement(InterfaceElement2 element) {
  if (element.name3 != 'Schema') {
    return false;
  }
  final uri = element.library2.uri;
  return uri.toString().startsWith('package:raindrop/');
}

/// All `.dart` files under [root], recursively.
List<String> _discoverDartFiles(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) {
    return const [];
  }
  final files = <String>[];
  for (final e in dir.listSync(recursive: true)) {
    if (e is! File) {
      continue;
    }
    if (!e.path.endsWith('.dart')) {
      continue;
    }
    files.add(p.normalize(p.absolute(e.path)));
  }
  files.sort();
  return files;
}
