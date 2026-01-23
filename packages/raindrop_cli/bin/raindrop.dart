import 'dart:io';

import 'package:raindrop_cli/src/cli/cli_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = CliRunner();
  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e.message);
    print('');
    print(e.usage);
    exit(64);
  } catch (e, st) {
    print('Error: $e');
    print(st);
    exit(1);
  }
}
