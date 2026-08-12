import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/dart_executable.dart';
import 'package:raindrop_cli/src/core/package_paths.dart';

/// Runs a generated Dart entrypoint and returns the map it replies with.
///
/// Both the schema snapshot and the DDL generator work the same way: write a
/// throwaway entrypoint, run it, talk to it over a port. The only question is
/// *how* to run it.
///
/// [Isolate.spawnUri] is the cheap path, but it can only load a source URI on
/// a VM that can still compile Dart — which an AOT `dart compile exe` binary
/// cannot. A CLI embedded in such a binary (zonai does exactly this) would
/// fail at the spawn. So when this process is not itself the Dart VM, the run
/// is handed to a `dart` subprocess running [ddlSubprocessHostPath], which
/// spawns the isolate on our behalf and prints the reply as JSON.
abstract final class EntrypointRunner {
  /// Path, inside `raindrop_cli`, of the script the subprocess path runs.
  static const ddlSubprocessHostPath = 'lib/src/ddl/ddl_subprocess_host.dart';

  /// Whether this process is a Dart VM rather than a compiled binary.
  static bool get isDartVm {
    final name = p.basename(Platform.resolvedExecutable).toLowerCase();
    return name == 'dart' || name == 'dart.exe';
  }

  /// Runs [entryPointUri], forwarding [message], and returns its reply.
  static Future<Map<String, Object?>> run(
    Uri entryPointUri,
    Map<String, Object?> message, {
    String? projectPath,
    Uri? packageConfig,
  }) {
    if (isDartVm) {
      return _inIsolate(entryPointUri, message, packageConfig: packageConfig);
    }
    return _inSubprocess(
      entryPointUri,
      message,
      projectPath: projectPath,
      packageConfig: packageConfig,
    );
  }

  static Future<Map<String, Object?>> _inIsolate(
    Uri entryPointUri,
    Map<String, Object?> message, {
    Uri? packageConfig,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    Isolate? isolate;
    try {
      isolate = await Isolate.spawnUri(
        entryPointUri,
        const [],
        receivePort.sendPort,
        onError: errorPort.sendPort,
        packageConfig: packageConfig,
      );

      // An entrypoint that fails to compile or throws while initialising never
      // sends its port, so race the error channel or this would hang.
      final failure = errorPort.first.then<Never>(
        (error) => throw StateError('The entrypoint could not be loaded:\n'
            '$error'),
      );
      final sendPort =
          await Future.any([receivePort.first, failure]) as SendPort;

      final responsePort = ReceivePort();
      sendPort.send({'replyPort': responsePort.sendPort, ...message});
      final response = await Future.any([responsePort.first, failure])
          as Map<Object?, Object?>;
      responsePort.close();

      return response.cast<String, Object?>();
    } finally {
      receivePort.close();
      errorPort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }

  static Future<Map<String, Object?>> _inSubprocess(
    Uri entryPointUri,
    Map<String, Object?> message, {
    String? projectPath,
    Uri? packageConfig,
  }) async {
    final workingDirectory = projectPath ?? Directory.current.path;

    final hostScript = await RaindropPackagePaths.packageFile(
      packageName: 'raindrop_cli',
      relativePath: ddlSubprocessHostPath,
      projectPath: projectPath,
    );
    if (hostScript == null) {
      throw StateError(
        'raindrop_cli package not found. Run "dart pub get" first.',
      );
    }

    // Passed as a file rather than on stdin: the payload can be large enough
    // to deadlock on a pipe buffer while both ends wait on each other.
    final messageFile = File(
      p.join(workingDirectory, '.dart_tool', 'raindrop', 'entrypoint_msg.json'),
    );
    messageFile.parent.createSync(recursive: true);
    messageFile.writeAsStringSync(jsonEncode(message));

    final process = await Process.start(
      await DartExecutable.resolve(projectRoot: workingDirectory),
      [
        hostScript.path,
        entryPointUri.toFilePath(),
        if (packageConfig != null) '--packages=${packageConfig.toFilePath()}',
        '--message-file=${messageFile.path}',
      ],
      workingDirectory: workingDirectory,
    );
    await process.stdin.close();

    final stdout = await process.stdout.transform(utf8.decoder).join();
    final stderr = await process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      final details = [stderr, stdout]
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join('\n');
      throw StateError(
        details.isEmpty
            ? 'The entrypoint subprocess failed (exit $exitCode).'
            : 'The entrypoint subprocess failed:\n$details',
      );
    }

    final trimmed = stdout.trim();
    if (trimmed.isEmpty) {
      throw StateError('The entrypoint subprocess returned no output.');
    }

    return (jsonDecode(trimmed) as Map<Object?, Object?>)
        .cast<String, Object?>();
  }
}
