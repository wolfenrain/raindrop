import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// How migration SQL filenames are prefixed (before `_description`).
enum MigrationNaming {
  /// `0000_`, `0001_`, … (default).
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
  switch (naming) {
    case MigrationNaming.integer:
      return migrationIndex.toString().padLeft(4, '0');
    case MigrationNaming.timestamp:
      return at.millisecondsSinceEpoch.toString().padLeft(15, '0');
  }
}

MigrationNaming _parseMigrationNaming(String? raw) {
  if (raw == null) {
    return MigrationNaming.integer;
  }
  switch (raw.toLowerCase().trim()) {
    case 'integer':
      return MigrationNaming.integer;
    case 'timestamp':
      return MigrationNaming.timestamp;
    default:
      throw StateError(
        'Invalid "migration_naming" in raindrop.yaml: "$raw". '
        'Use "integer" or "timestamp".',
      );
  }
}

/// Configuration for the raindrop CLI tool.
class RaindropConfig {
  const RaindropConfig({
    required this.schemaPath,
    required this.outPath,
    required this.configDir,
    required this.dialect,
    this.dartPath,
    this.migrationNaming = MigrationNaming.integer,
  });

  /// Path to the directory containing schema files (absolute path).
  final String schemaPath;

  /// Path to the output directory for migrations (absolute path).
  final String outPath;

  /// The SQL dialect to use (postgres or sqlite).
  final String dialect;

  /// Optional path to generate a Dart migrations file (absolute path).
  /// If set, `generate` also produces this Dart file alongside .sql files.
  final String? dartPath;

  /// Prefix style for generated migration SQL filenames (`0000_…` vs epoch `…_`).
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
        'Create a raindrop.yaml file with at least a "dialect" field.',
      );
    }

    final content = await file.readAsString();
    final yaml = loadYaml(content) as YamlMap?;

    final dialect = yaml?['dialect'] as String?;
    if (dialect == null) {
      throw StateError(
        'Missing required "dialect" field in $path.\n'
        'Specify the dialect of the package you are using.',
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
      dialect: dialect,
      configDir: configDir,
      dartPath: dartPath,
      migrationNaming: migrationNaming,
    );
  }
}
