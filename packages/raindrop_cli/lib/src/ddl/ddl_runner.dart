import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:raindrop/ddl.dart';
import 'package:raindrop_cli/src/core/dart_executable.dart';
import 'package:raindrop_cli/src/core/package_paths.dart';

/// Runs DDL generation in an isolated process by dynamically loading
/// the appropriate dialect package's DDL generator.
class DdlRunner {
  DdlRunner._();

  /// Generates SQL DDL from the given operations using the specified dialect.
  ///
  /// This method:
  /// 1. Resolves the dialect package location from the user's pub cache
  /// 2. Spawns an isolate that loads the DDL generator
  /// 3. Sends the operations and receives the generated SQL
  ///
  /// Throws an [ArgumentError] if the dialect package is not found.
  static Future<String> generate(
    String dialect,
    List<DiffOperation> operations, {
    String? projectPath,
  }) async {
    final entryPointUri = await _resolveEntryPoint(dialect, projectPath);

    final configFile = _findPackageConfig(projectPath);

    final message = {
      'action': 'generate',
      'operations': operations.map((op) => op.toMap()).toList(),
    };
    final packageConfig =
        configFile != null ? Uri.file(configFile.path) : null;

    final response = await _runCommand(
      entryPointUri,
      message,
      projectPath: projectPath,
      packageConfig: packageConfig,
    );

    return response['sql'] as String;
  }

  /// Resolves the entry point URI for a dialect package.
  static Future<Uri> _resolveEntryPoint(
    String dialect,
    String? projectPath,
  ) async {
    final packageUri = await _resolveDialectPackage(dialect, projectPath);
    if (packageUri == null) {
      throw ArgumentError(
        'Dialect package "raindrop_$dialect" not found. '
        'Make sure it is listed in your pubspec.yaml dependencies.',
      );
    }

    return Uri.parse('$packageUri/lib/src/${dialect}_ddl.dart');
  }

  /// Resolves the package URI for the given dialect from package_config.json.
  static Future<Uri?> _resolveDialectPackage(
    String dialect,
    String? projectPath,
  ) async {
    final packageName = 'raindrop_$dialect';
    final configFile = _findPackageConfig(projectPath);

    if (configFile == null) {
      throw StateError(
        'package_config.json not found. Run "dart pub get" first.',
      );
    }

    final configContent = await configFile.readAsString();
    final config = jsonDecode(configContent) as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;

    for (final pkg in packages) {
      final pkgMap = pkg as Map<String, dynamic>;
      if (pkgMap['name'] == packageName) {
        final rootUri = pkgMap['rootUri'] as String;
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

  static bool get _isDartVm {
    final name = p.basename(Platform.resolvedExecutable).toLowerCase();
    return name == 'dart' || name == 'dart.exe';
  }

  static Future<Map<String, dynamic>> _runCommand(
    Uri entryPointUri,
    Map<String, dynamic> message, {
    required String? projectPath,
    Uri? packageConfig,
  }) async {
    if (_isDartVm) {
      return _runInIsolate(
        entryPointUri,
        message,
        packageConfig: packageConfig,
      );
    }

    return _runInSubprocess(
      entryPointUri,
      message,
      projectPath: projectPath,
      packageConfig: packageConfig,
    );
  }

  static Future<Map<String, dynamic>> _runInSubprocess(
    Uri entryPointUri,
    Map<String, dynamic> message, {
    required String? projectPath,
    Uri? packageConfig,
  }) async {
    final hostScript = await RaindropPackagePaths.packageFile(
      packageName: 'raindrop_cli',
      relativePath: 'lib/src/ddl/ddl_subprocess_host.dart',
      projectPath: projectPath,
    );
    if (hostScript == null) {
      throw StateError(
        'raindrop_cli package not found. Run "dart pub get" first.',
      );
    }

    final dart = await DartExecutable.resolve(
      projectRoot: projectPath ?? Directory.current.path,
    );
    final args = <String>[
      hostScript.path,
      entryPointUri.toFilePath(),
      if (packageConfig != null) '--packages=${packageConfig.toFilePath()}',
    ];

    final workingDirectory = projectPath ?? Directory.current.path;
    final messageFile = File(
      p.join(workingDirectory, '.dart_tool', 'raindrop', 'ddl_message.json'),
    );
    messageFile.parent.createSync(recursive: true);
    messageFile.writeAsStringSync(jsonEncode(message));
    args.add('--message-file=${messageFile.path}');

    final process = await Process.start(
      dart,
      args,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.normal,
    );
    await process.stdin.close();

    final stdout = await process.stdout.transform(utf8.decoder).join();
    final stderr = await process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      final details = [
        stderr,
        stdout,
      ].map((s) => s.trim()).where((s) => s.isNotEmpty).join('\n');
      throw StateError(
        details.isEmpty
            ? 'DDL subprocess failed (exit $exitCode).'
            : 'DDL subprocess failed:\n$details',
      );
    }

    final trimmed = stdout.trim();
    if (trimmed.isEmpty) {
      throw StateError('DDL subprocess returned no output.');
    }

    return jsonDecode(trimmed) as Map<String, dynamic>;
  }

  static Future<File?> _resolvePackageFile(
    String packageName,
    String relativePath,
    String? projectPath,
  ) async {
    return RaindropPackagePaths.packageFile(
      packageName: packageName,
      relativePath: relativePath,
      projectPath: projectPath,
    );
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

      // Wait for the isolate to send back its SendPort
      final isolateSendPort = await receivePort.first as SendPort;

      // Create a port for the response
      final responsePort = ReceivePort();

      // Send the message with the reply port
      isolateSendPort.send({
        'replyPort': responsePort.sendPort,
        ...message,
      });

      // Wait for the response
      final response = await responsePort.first as Map<String, dynamic>;
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

  /// Discovers all dialect packages available in the project.
  ///
  /// Returns a list of dialect names (e.g., ['postgres', 'sqlite']).
  static Future<List<String>> discoverDialects({String? projectPath}) async {
    final configFile = _findPackageConfig(projectPath);
    if (configFile == null) {
      return [];
    }

    final configContent = await configFile.readAsString();
    final config = jsonDecode(configContent) as Map<String, dynamic>;
    final packages = config['packages'] as List<dynamic>;

    final dialects = <String>[];
    for (final pkg in packages) {
      final pkgMap = pkg as Map<String, dynamic>;
      final name = pkgMap['name'] as String;
      if (name.startsWith('raindrop_') && name != 'raindrop_cli') {
        dialects.add(name.substring('raindrop_'.length));
      }
    }

    return dialects;
  }
}
