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
      help: 'Path to the configuration file. If the file does not exist, '
          'use --dialect, --schemas, and --out instead.',
      defaultsTo: 'raindrop.yaml',
    );
    argParser.addOption(
      'dialect',
      help: 'SQL dialect (e.g. sqlite, postgres). Required when no config file '
          'exists; otherwise overrides raindrop.yaml when passed.',
    );
    argParser.addOption(
      'schemas',
      help: 'Directory of schema Dart files (relative to the config file '
          'directory, or to the current directory when there is no config file). '
          'Required when no config file exists.',
    );
    argParser.addOption(
      'out',
      help:
          'Directory for generated migrations (same resolution as --schemas). '
          'Required when no config file exists.',
    );
    argParser.addOption(
      'migration-naming',
      help: 'Migration filename prefix style: integer (default) or timestamp. '
          'Overrides raindrop.yaml when passed.',
      allowed: ['integer', 'timestamp'],
    );
    argParser.addOption(
      'dart',
      help: 'Optional path for generated Dart migrations embedding (relative '
          'resolution matches --schemas). Overrides raindrop.yaml "dart:" when passed.',
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
