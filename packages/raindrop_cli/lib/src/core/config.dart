import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// How migration SQL filenames are prefixed (before `_description`).
enum MigrationNaming {
  /// `0000_`, `0001_`, ... (default).
  integer,

  /// Milliseconds since epoch, zero-padded to 15 digits for stable
  /// lexicographic sort when loading `*.sql` from disk.
  timestamp,
}

/// Builds the prefix segment of a migration tag (before `_name`).
String migrationTagPrefix({
  required MigrationNaming naming,
  required int migrationIndex,
  required DateTime at,
}) {
  return switch (naming) {
    MigrationNaming.integer => migrationIndex.toString().padLeft(4, '0'),
    MigrationNaming.timestamp =>
      at.millisecondsSinceEpoch.toString().padLeft(15, '0'),
  };
}

MigrationNaming _parseMigrationNaming(String? raw) {
  return switch (raw?.toLowerCase().trim()) {
    'integer' || null => MigrationNaming.integer,
    'timestamp' => MigrationNaming.timestamp,
    _ => throw StateError(
        '''
Invalid "migration_naming" in raindrop.yaml: "$raw". Use "integer" or "timestamp".''',
      ),
  };
}

/// Configuration for the raindrop CLI tool.
class RaindropConfig {
  /// Creates a configuration from already-resolved absolute paths.
  const RaindropConfig({
    required this.schemaPath,
    required this.outPath,
    required this.configDir,
    required this.driver,
    this.dartPath,
    this.migrationNaming = MigrationNaming.integer,
  });

  /// Path to the directory containing schema files (absolute path).
  final String schemaPath;

  /// Path to the output directory for migrations (absolute path).
  final String outPath;

  /// The driver package name (`raindrop_sqlite`).
  ///
  /// The exact package the CLI introspects schemas with and loads the DDL
  /// generator from.
  final String driver;

  /// Optional path to generate a Dart migrations file (absolute path).
  /// If set, `generate` also produces this Dart file alongside .sql files.
  final String? dartPath;

  /// Prefix style for generated migration SQL filenames (`0000_...` vs
  /// epoch `..._`).
  final MigrationNaming migrationNaming;

  /// Directory containing the config file (absolute path).
  /// Used for resolving relative paths.
  final String configDir;

  /// Path to the meta directory (contains journal and snapshots).
  String get metaPath => p.join(outPath, 'meta');

  /// Path to the journal file.
  String get journalPath => p.join(metaPath, '_journal.json');

  /// Gets the snapshot path for a given migration index.
  String snapshotPath(int index) {
    final indexStr = index.toString().padLeft(4, '0');
    return p.join(metaPath, '${indexStr}_snapshot.json');
  }

  /// Load configuration from a YAML file.
  ///
  /// Paths in the config file are resolved relative to the config file's
  /// directory, allowing config files to be placed anywhere in the project.
  static Future<RaindropConfig> load(String path) async {
    final file = File(path);
    final configDir = p.dirname(p.absolute(path));

    if (!file.existsSync()) {
      throw StateError(
        'Configuration file not found: $path\n'
        'Create a raindrop.yaml file with at least a "driver" field.',
      );
    }

    final content = await file.readAsString();
    final yaml = loadYaml(content) as YamlMap?;

    final driver = yaml?['driver'] as String?;
    if (driver == null) {
      throw StateError(
        'Missing required "driver" field in $path.\n'
        'Set it to your driver package name (e.g. "driver: raindrop_sqlite").',
      );
    }

    // Resolve paths relative to config file location
    final schemaPath = p.normalize(
      p.join(configDir, yaml?['schemas'] as String? ?? 'lib/database'),
    );
    final outPath = p.normalize(
      p.join(configDir, yaml?['out'] as String? ?? 'migrations'),
    );

    // Resolve optional dart output path
    final dartRaw = yaml?['dart'] as String?;
    final dartPath =
        dartRaw != null ? p.normalize(p.join(configDir, dartRaw)) : null;

    final migrationNaming =
        _parseMigrationNaming(yaml?['migration_naming'] as String?);

    return RaindropConfig(
      schemaPath: schemaPath,
      outPath: outPath,
      driver: driver,
      configDir: configDir,
      dartPath: dartPath,
      migrationNaming: migrationNaming,
    );
  }

  /// Loads config from `raindrop.yaml` when present, otherwise requires
  /// `--driver`, `--schemas`, and `--out` on [global].
  ///
  /// When a YAML file exists, any CLI flag that was explicitly passed overrides
  /// the corresponding YAML field (paths are relative to the YAML file's
  /// directory). When there is no YAML file, paths are relative to the current
  /// working directory.
  static Future<RaindropConfig> loadResolved(ArgResults global) async {
    final configPath = global['config'] as String;
    final file = File(configPath);
    final hasConfig = file.existsSync();

    final driver = global['driver'] as String?;
    final schemas = global['schemas'] as String?;
    final out = global['out'] as String?;
    final migrationNaming = global['migration-naming'] as String?;
    final dart = global['dart'] as String?;

    final baseDir = Directory.current.path;

    if (!hasConfig) {
      if (driver == null || schemas == null || out == null) {
        throw StateError(
          'Configuration file not found: $configPath\n'
          'Create raindrop.yaml or pass --driver, --schemas, and --out.',
        );
      }

      return RaindropConfig(
        schemaPath: p.normalize(p.join(baseDir, global['schemas'] as String)),
        outPath: p.normalize(p.join(baseDir, global['out'] as String)),
        driver: global['driver'] as String,
        configDir: baseDir,
        dartPath: dart != null && dart.isNotEmpty
            ? p.normalize(p.join(baseDir, dart))
            : null,
        migrationNaming: _parseMigrationNaming(migrationNaming),
      );
    }

    final base = await RaindropConfig.load(configPath);

    return RaindropConfig(
      schemaPath: schemas != null
          ? p.normalize(p.join(baseDir, schemas))
          : base.schemaPath,
      outPath: out != null ? p.normalize(p.join(baseDir, out)) : base.outPath,
      driver: driver ?? base.driver,
      configDir: base.configDir,
      dartPath:
          dart != null ? p.normalize(p.join(baseDir, dart)) : base.dartPath,
      migrationNaming: _parseMigrationNaming(migrationNaming),
    );
  }
}
