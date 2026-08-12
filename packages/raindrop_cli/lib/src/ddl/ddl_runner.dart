import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:raindrop/ddl.dart';

import 'package:raindrop_cli/src/core/entrypoint_runner.dart';

/// Runs DDL generation in an isolated process by dynamically loading
/// the appropriate driver package's DDL generator.
class DdlRunner {
  DdlRunner._(); // coverage:ignore-line

  /// Generates SQL DDL from the given operations using the given [driver]
  /// package.
  ///
  /// This method:
  /// 1. Resolves the driver package location from the user's package config
  /// 2. Spawns an isolate that loads the DDL generator
  /// 3. Sends the operations and receives the generated SQL
  ///
  /// Throws an [ArgumentError] if the driver package is not found.
  static Future<String> generate(
    String driver,
    List<DiffOperation> operations, {
    String? projectPath,
  }) async {
    final entryPointUri = await _resolveEntryPoint(driver, projectPath);

    final configFile = _findPackageConfig(projectPath);

    final response = await EntrypointRunner.run(
      entryPointUri,
      {
        'action': 'generate',
        'operations': operations.map((op) => op.toMap()).toList(),
      },
      projectPath: projectPath,
      packageConfig: configFile != null ? Uri.file(configFile.path) : null,
    );

    if (response['success'] != true) {
      throw Exception('DDL operation failed: ${response['error']}');
    }

    return response['sql'] as String;
  }

  /// Resolves the entry point URI for a driver package.
  static Future<Uri> _resolveEntryPoint(
    String driver,
    String? projectPath,
  ) async {
    final packageUri = await resolveDriverPackage(driver, projectPath);
    if (packageUri == null) {
      throw ArgumentError(
        '''
Driver package "$driver" not found. Make sure the "driver" field in raindrop.yaml names a package listed in your pubspec.yaml dependencies.''',
      );
    }

    return Uri.parse('$packageUri/lib/ddl.dart');
  }

  /// Resolves the [driver] package's root URI from package_config.json.
  @visibleForTesting
  static Future<Uri?> resolveDriverPackage(
    String driver,
    String? projectPath,
  ) async {
    final configFile = _findPackageConfig(projectPath);

    if (configFile == null) {
      throw StateError(
        'package_config.json not found. Run "dart pub get" first.',
      );
    }

    final configContent = await configFile.readAsString();
    final config = jsonDecode(configContent) as Map<String, dynamic>;
    final packages =
        (config['packages'] as List<dynamic>).cast<Map<String, dynamic>>();

    for (final pkg in packages) {
      if (pkg['name'] != driver) continue;

      final rootUri = pkg['rootUri'] as String;
      // rootUri can be relative (e.g., "../raindrop_postgres") or absolute
      if (rootUri.startsWith('file://')) {
        return Uri.parse(rootUri);
      } else {
        // Relative path - resolve against package_config.json location
        final configDir = p.dirname(configFile.path);
        final absolutePath = p.normalize(p.join(configDir, rootUri));
        return Uri.file(absolutePath);
      }
    }

    return null;
  }

  /// Finds the package_config.json file by walking up the directory tree.
  ///
  /// This handles Dart workspaces where the package_config.json may be at the
  /// workspace root rather than in the immediate project directory.
  static File? _findPackageConfig(String? projectPath) {
    var current = Directory(projectPath ?? Directory.current.path).absolute;

    while (true) {
      final configFile = File(
        p.join(current.path, '.dart_tool', 'package_config.json'),
      );
      if (configFile.existsSync()) {
        return configFile;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        break;
      }
      current = parent;
    }

    return null;
  }
}
