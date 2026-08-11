import 'package:raindrop_cli/src/cli/commands/generate.dart';
import 'package:raindrop_cli/src/cli/commands/status.dart';
import 'package:test/test.dart';

void main() {
  test('generate names and describes itself', () {
    final command = GenerateCommand();
    expect(command.name, 'generate');
    expect(command.description, contains('migration'));
  });

  test('status names and describes itself', () {
    final command = StatusCommand();
    expect(command.name, 'status');
    expect(command.description, contains('status'));
  });
}
