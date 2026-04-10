import 'package:args/args.dart';

/// Global raindrop CLI options shared by [CliRunner] and
/// [RaindropConfig.loadFromGlobalArgs].
void addRaindropGlobalOptions(ArgParser parser) {
  parser.addFlag(
    'version',
    abbr: 'v',
    negatable: false,
    help: 'Print the version of raindrop_cli.',
  );
  parser.addOption(
    'config',
    abbr: 'c',
    help: 'Path to the configuration file. If the file does not exist, '
        'use --dialect, --schemas, and --out instead.',
    defaultsTo: 'raindrop.yaml',
  );
  parser.addOption(
    'dialect',
    help: 'SQL dialect (e.g. sqlite, postgres). Required when no config file '
        'exists; otherwise overrides raindrop.yaml when passed.',
  );
  parser.addOption(
    'schemas',
    help: 'Directory of schema Dart files (relative to the config file '
        'directory, or to the current directory when there is no config file). '
        'Required when no config file exists.',
  );
  parser.addOption(
    'out',
    help: 'Directory for generated migrations (same resolution as --schemas). '
        'Required when no config file exists.',
  );
  parser.addOption(
    'migration-naming',
    help: 'Migration filename prefix style: integer (default) or timestamp. '
        'Overrides raindrop.yaml when passed.',
    allowed: ['integer', 'timestamp'],
  );
  parser.addOption(
    'dart',
    help: 'Optional path for generated Dart migrations embedding (relative '
        'resolution matches --schemas). Overrides raindrop.yaml "dart:" when passed.',
  );
}
