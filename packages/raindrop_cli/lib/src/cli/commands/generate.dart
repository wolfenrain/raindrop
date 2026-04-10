import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/config.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/journal.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:raindrop_cli/src/ddl/ddl_runner.dart';
import 'package:raindrop_cli/src/parser/schema_parser.dart';

/// Command to generate a new migration from schema changes.
class GenerateCommand extends Command<int> {
  GenerateCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Name for the migration.',
      mandatory: true,
    );
    argParser.addFlag(
      'dry-run',
      help: 'Show what would be generated without creating files.',
      defaultsTo: false,
    );
    argParser.addOption(
      'dart',
      help: 'Generate a Dart file with embedded migrations at the given path. '
          'Defaults to {out}/migrations.dart if no path is provided.',
    );
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate a new SQL migration from schema changes.';

  @override
  Future<int> run() async {
    final migrationName = argResults!['name'] as String;
    final dryRun = argResults!['dry-run'] as bool;
    final configPath = globalResults!['config'] as String;

    // Load configuration
    final config = await RaindropConfig.load(configPath);

    // Determine dart output path.
    final dartOutputPath = switch (argResults!['dart'] as String?) {
      final String path => p.normalize(p.join(config.configDir, path)),
      _ => config.dartPath,
    };

    // Load the journal
    final journal = await MigrationJournal.load(
      config.journalPath,
      config.dialect,
    );

    // Load previous snapshot if it exists
    SchemaSnapshot? previousSnapshot;
    if (journal.entries.isNotEmpty) {
      final lastEntry = journal.entries.last;
      final snapshotPath = config.snapshotPath(lastEntry.idx);
      previousSnapshot = await SchemaSnapshot.load(snapshotPath);
    }

    // Parse current schema with prevId from journal
    final parser = SchemaParser();
    final currentSnapshot = await parser.parseDirectory(
      config.schemaPath,
      dialect: config.dialect,
      prevId: journal.previousId,
    );

    if (currentSnapshot.tables.isEmpty) {
      print(
          'No tables found for "${config.dialect}" in schema directory: ${config.schemaPath}');
      return 1;
    }

    // Calculate diff
    final differ = SchemaDiffer();
    final operations = differ.diff(previousSnapshot, currentSnapshot);

    if (operations.isEmpty) {
      print('No schema changes detected.');
      return 0;
    }

    // Find project root (where pubspec.yaml lives) for package resolution
    final projectPath = _findProjectRoot(config.configDir);

    // Determine migration index and tag
    final migrationIndex = journal.nextIndex;
    final indexStr = migrationIndex.toString().padLeft(4, '0');
    final tag = '${indexStr}_${_sanitizeName(migrationName)}';

    // Generate SQL using the dialect's DDL generator via isolate
    final sql = await DdlRunner.generate(
      currentSnapshot.dialect,
      operations,
      projectPath: projectPath,
    );

    // The differ can emit operations the dialect does not turn into SQL (e.g.
    // metadata-only column changes). Do not write an empty migration file.
    if (sql.trim().isEmpty) {
      print(
        'No changes were made; nothing to migrate (no SQL for the current diff).',
      );
      return 0;
    }

    if (dryRun) {
      print('Would generate migration: $tag.sql');
      print('');
      print('SQL:');
      print(sql);
      return 0;
    }

    // Create migration directory
    final migrationDir = Directory(config.outPath);
    if (!migrationDir.existsSync()) {
      migrationDir.createSync(recursive: true);
    }

    // Create meta directory
    final metaDir = Directory(config.metaPath);
    if (!metaDir.existsSync()) {
      metaDir.createSync(recursive: true);
    }

    final migrationPath = p.join(config.outPath, '$tag.sql');
    await File(migrationPath).writeAsString(sql);

    // Save the snapshot
    final snapshotPath = config.snapshotPath(migrationIndex);
    await currentSnapshot.save(snapshotPath);

    // Update the journal
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final entry = JournalEntry(
      idx: migrationIndex,
      version: SchemaSnapshot.currentVersion,
      when: timestamp,
      tag: tag,
      snapshotId: currentSnapshot.id,
    );

    final updatedJournal = switch (journal.entries.isEmpty) {
      true => MigrationJournal(
          version: MigrationJournal.currentVersion,
          dialect: currentSnapshot.dialect,
          entries: [entry],
        ),
      false => journal.addEntry(entry),
    };

    await updatedJournal.save(config.journalPath);

    // Write Dart migrations file if configured or --dart flag passed
    if (dartOutputPath != null) {
      await _generateDartFile(config, updatedJournal, dartOutputPath);
    }

    print('Generated migration: $migrationPath');
    if (dartOutputPath != null) {
      print('Generated Dart migrations file: $dartOutputPath');
    }
    print('');
    print('Changes:');
    for (final op in operations) {
      print('  - ${op.describe()}');
    }

    return 0;
  }

  Future<void> _generateDartFile(
    RaindropConfig config,
    MigrationJournal journal,
    String outputPath,
  ) async {
    final buffer = StringBuffer()
      ..writeln("import 'package:raindrop/raindrop.dart';")
      ..writeln()
      ..writeln('/// Generated migrations. Do not edit by hand.')
      ..writeln('final migrations = [');

    for (final entry in journal.entries) {
      final sql =
          await File(p.join(config.outPath, '${entry.tag}.sql')).readAsString();
      final escapedSql = sql.replaceAll("'''", r"\'''");
      buffer
        ..writeln("  const Migration('${entry.tag}', '''")
        ..write(escapedSql)
        ..writeln("'''),");
    }

    buffer.writeln('];');

    final dartFile = File(outputPath);
    final dartDir = Directory(dartFile.parent.path);
    if (!dartDir.existsSync()) {
      dartDir.createSync(recursive: true);
    }
    await dartFile.writeAsString(buffer.toString());
  }

  String _sanitizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  /// Find the project root by walking up from the given directory until
  /// finding a pubspec.yaml file.
  String _findProjectRoot(String startDir) {
    var current = startDir;
    while (true) {
      final pubspecPath = p.join(current, 'pubspec.yaml');
      if (File(pubspecPath).existsSync()) {
        return current;
      }
      final parent = p.dirname(current);
      if (parent == current) {
        // Reached filesystem root without finding pubspec.yaml
        // Fall back to config directory
        return startDir;
      }
      current = parent;
    }
  }
}
