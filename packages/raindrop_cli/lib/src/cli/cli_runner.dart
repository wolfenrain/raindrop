import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:raindrop_cli/src/cli/commands/generate.dart';
import 'package:raindrop_cli/src/cli/commands/status.dart';
import 'package:raindrop_cli/src/version.dart';

export 'package:args/command_runner.dart' show UsageException;

/// The CLI runner for the raindrop command line tool.
class CliRunner extends CommandRunner<int> {
  /// Creates the runner, registering the global options and the `generate`
  /// and `status` subcommands.
  CliRunner()
      : super(
          'raindrop',
          '''
CLI tool for generating SQL migrations from Raindrop schema definitions.''',
        ) {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the version of raindrop_cli.',
      )
      ..addOption(
        'config',
        abbr: 'c',
        help: '''
Path to the configuration file. If the file does not exist, use --driver, --schemas, and --out instead.''',
        defaultsTo: 'raindrop.yaml',
      )
      ..addOption(
        'driver',
        help: '''
Driver package name (e.q. raindrop_sqlite). Required when no config file exists, otherwise overrides raindrop.yaml when passed.''',
      )
      ..addOption(
        'schemas',
        help: '''
Directory of schema Dart files (relative to the config file directory, or to the current directory when there is no config file). Required when no config file exists.''',
      )
      ..addOption(
        'out',
        help: '''
Directory for generated migrations (same resolution as --schemas). Required when no config file exists.''',
      )
      ..addOption(
        'migration-naming',
        help: '''
Migration filename prefix style: integer (default) or timestamp. Overrides raindrop.yaml when passed.''',
        allowed: ['integer', 'timestamp'],
      )
      ..addOption(
        'dart',
        help: '''
Optional path for generated Dart migrations embedding (relative resolution matches --schemas). Overrides raindrop.yaml "dart:" when passed.''',
      );

    addCommand(GenerateCommand());
    addCommand(StatusCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    final results = parse(args);

    if (results['version'] as bool) {
      stdout.writeln('raindrop_cli version $packageVersion');
      return 0;
    }

    return await super.run(args) ?? 0;
  }
}
