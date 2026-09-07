import 'dart:isolate';

import 'package:raindrop/ddl.dart';

/// Serves [generator] over the isolate command protocol the CLI speaks.
///
/// Sends a command port back over [sendPort], then answers `generate`
/// messages until the returned [ReceivePort] is closed.
///
/// A driver's DDL entrypoint is the only place this belongs:
///
/// ```dart
/// void main(List<String> args, SendPort sendPort) =>
///     serveDdlGenerator(MyDdlGenerator(), sendPort);
/// ```
ReceivePort serveDdlGenerator(DdlGenerator generator, SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final replyPort = message['replyPort'] as SendPort;
      final action = message['action'] as String? ?? 'generate';

      try {
        switch (action) {
          case 'generate':
            final sql = generator.generate(
              (message['operations'] as List<dynamic>)
                  .map((o) => DiffOperation.fromMap((o as Map).cast()))
                  .toList(),
            );

            replyPort.send({'success': true, 'sql': sql});
          default:
            replyPort.send(
              {'success': false, 'error': 'Unknown action: $action'},
            );
        }
      } on Object catch (e, st) {
        replyPort.send({'success': false, 'error': '$e\n$st'});
      }
    }
  });

  return receivePort;
}
