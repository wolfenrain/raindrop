import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

/// Runs [DdlRunner] isolate logic in a `dart` subprocess.
///
/// Usage:
/// ```sh
/// dart ddl_subprocess_host.dart <entryPoint> [--packages=<packageConfig>] \
///   < message.json
/// ```
///
/// Writes a JSON response map to stdout.
void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart ddl_subprocess_host.dart <entryPoint> '
        '[--packages=<packageConfig>]');
    exitCode = 64;
    return;
  }

  final entryPoint = Uri.file(args[0]);
  Uri? packageConfig;
  String? messageFilePath;
  for (final arg in args.skip(1)) {
    if (arg.startsWith('--packages=')) {
      packageConfig = Uri.file(arg.substring('--packages='.length));
    } else if (arg.startsWith('--message-file=')) {
      messageFilePath = arg.substring('--message-file='.length);
    }
  }

  final message = switch (messageFilePath) {
    final String path =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>,
    _ => jsonDecode(
          await stdin.transform(utf8.decoder).join(),
        ) as Map<String, dynamic>,
  };

  try {
    final response = await _runInIsolate(
      entryPoint,
      message,
      packageConfig: packageConfig,
    );
    stdout.writeln(jsonEncode(response));
  } catch (e, st) {
    stdout.writeln(jsonEncode({'success': false, 'error': '$e\n$st'}));
    exitCode = 1;
  }
}

Future<Map<String, dynamic>> _runInIsolate(
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

    // An entrypoint that fails to compile or throws while initialising never
    // sends its port, so race the error channel or this would hang forever --
    // and this is the path an AOT-compiled CLI always takes.
    final failure = errorPort.first.then<Never>(
      (error) => throw StateError('The entrypoint could not be loaded:\n$error'),
    );

    final isolateSendPort =
        await Future.any([receivePort.first, failure]) as SendPort;
    final responsePort = ReceivePort();

    isolateSendPort.send({
      'replyPort': responsePort.sendPort,
      ...message,
    });

    final response = await Future.any([responsePort.first, failure])
        as Map<String, dynamic>;
    responsePort.close();

    if (response['success'] == true) {
      return response;
    }

    throw Exception('DDL operation failed: ${response['error']}');
  } finally {
    receivePort.close();
    errorPort.close();
    isolate?.kill(priority: Isolate.immediate);
  }
}
