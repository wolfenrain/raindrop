import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'package:raindrop_cli/src/cli/commands/generate.dart';
import 'package:raindrop_cli/src/cli/commands/status.dart';

export 'package:args/command_runner.dart' show UsageException;

/// The CLI runner for the raindrop command line tool.
class CliRunner extends CommandRunner<int> {
  CliRunner()
      : super(
          'raindrop',
          'CLI tool for generating SQL migrations from Raindrop schema definitions.',
        ) {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the version of raindrop_cli.',
    );
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration file.',
      defaultsTo: 'raindrop.yaml',
    );

    addCommand(GenerateCommand());
    addCommand(StatusCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    final results = parse(args);

    if (results['version'] as bool) {
      print('raindrop_cli version 0.1.0');
      return 0;
    }

    return await super.run(args) ?? 0;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    return await super.runCommand(topLevelResults);
  }
}
