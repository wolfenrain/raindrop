import 'dart:io';

import 'package:raindrop_cli/src/cli/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = CliRunner();
  try {
    exitCode = await runner.run(arguments);
  } on UsageException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln(e.usage);
    exit(64);
  } on Object catch (e, st) {
    stderr
      ..writeln('Error: $e')
      ..writeln(st);
    exit(1);
  }
}
