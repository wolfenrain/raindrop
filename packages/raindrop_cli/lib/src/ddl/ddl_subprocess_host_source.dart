/// Embedded copy of [ddl_subprocess_host.dart] for compiled hosts that lack
/// raindrop_cli on disk. Keep in sync with ddl_subprocess_host.dart.
const ddlSubprocessHostSource = '''
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

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
    stdout.writeln(jsonEncode({'success': false, 'error': '\$e\\n\$st'}));
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

    final isolateSendPort = await receivePort.first as SendPort;
    final responsePort = ReceivePort();

    isolateSendPort.send({
      'replyPort': responsePort.sendPort,
      ...message,
    });

    final response = await responsePort.first as Map<String, dynamic>;
    responsePort.close();

    if (response['success'] == true) {
      return response;
    }

    throw Exception('DDL operation failed: \${response['error']}');
  } finally {
    receivePort.close();
    errorPort.close();
    isolate?.kill(priority: Isolate.immediate);
  }
}
''';
