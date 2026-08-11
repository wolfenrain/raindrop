import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:raindrop/ddl.dart';

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

    final response = await _runInIsolate(
      entryPointUri,
      {
        'action': 'generate',
        'operations': operations.map((op) => op.toMap()).toList(),
      },
      packageConfig: configFile != null ? Uri.file(configFile.path) : null,
    );

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

  /// Runs a command in an isolate and returns the response.
  static Future<Map<String, dynamic>> _runInIsolate(
    Uri entryPointUri,
    Map<String, dynamic> message, {
    Uri? packageConfig,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();

    Isolate? isolate;
    try {
      isolate = await Isolate.spawnUri(
        entryPointUri,
        [],
        receivePort.sendPort,
        onError: errorPort.sendPort,
        packageConfig: packageConfig,
      );

      // A generator that fails to compile or throws while initialising never
      // sends its port, so race the error channel or this would hang.
      final failure = errorPort.first.then((error) => throw StateError(
            'The DDL generator could not be loaded:\n$error',
          ));
      final isolateSendPort =
          await Future.any([receivePort.first, failure]) as SendPort;

      // Create a port for the response
      final responsePort = ReceivePort();

      // Send the message with the reply port
      isolateSendPort.send({
        'replyPort': responsePort.sendPort,
        ...message,
      });

      // Wait for the response
      final response = await Future.any([responsePort.first, failure])
          as Map<String, dynamic>;
      responsePort.close();

      if (response['success'] == true) {
        return response;
      } else {
        throw Exception('DDL operation failed: ${response['error']}');
      }
    } finally {
      receivePort.close();
      errorPort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }
}
