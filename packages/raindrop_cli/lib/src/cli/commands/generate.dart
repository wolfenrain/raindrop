import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/config.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/emitter.dart';
import 'package:raindrop_cli/src/core/journal.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:raindrop_cli/src/ddl/ddl_runner.dart';
import 'package:raindrop_cli/src/introspect/snapshot_runner.dart';

/// Command to generate a new SQL migration.
class GenerateCommand extends Command<int> {
  /// Creates the command, registering its options and flags.
  GenerateCommand() {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Name for the migration.',
      )
      ..addFlag(
        'empty',
        help: 'Write a migration for by hand.',
      )
      ..addFlag(
        'dart-only',
        help: 'Rewrite the embedded Dart migrations from the journal and stop.',
      )
      ..addFlag(
        'dry-run',
        help: 'Show what would be generated without creating files.',
      )
      ..addOption(
        'dart',
        help: '''
Generate a Dart file with embedded migrations at the given path. Defaults to {out}/migrations.dart if no path is provided.''',
      )
      ..addOption(
        'current-snapshot',
        help: '''
Use a pre-built schema snapshot (JSON) as the current state instead of running the schema.''',
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate a new SQL migration.';

  @override
  Future<int> run() async {
    final empty = argResults!['empty'] as bool;
    final dartOnly = argResults!['dart-only'] as bool;
    final dryRun = argResults!['dry-run'] as bool;

    final config = await RaindropConfig.loadResolved(globalResults!);

    final dartOutputPath = switch (argResults!['dart'] as String?) {
      final String path => p.normalize(p.join(config.configDir, path)),
      _ => config.dartPath,
    };

    final journal = await MigrationJournal.load(config.journalPath);

    if (dartOnly) {
      return _emitOnly(config, journal, dartOutputPath);
    }

    final migrationName = argResults!['name'] as String?;
    if (migrationName == null || migrationName.trim().isEmpty) {
      stderr.writeln('Missing --name.');
      return 1;
    }

    SchemaSnapshot? previousSnapshot;
    if (journal.entries.isNotEmpty) {
      previousSnapshot = await SchemaSnapshot.load(
        config.snapshotPath(journal.entries.last.idx),
      );
    }

    // Built even for --empty, so that pending schema changes can be DETECTED.
    final SchemaSnapshot currentSnapshot;
    if (argResults!['current-snapshot'] case final String snapshotArg) {
      final loaded = await SchemaSnapshot.load(
        p.normalize(p.join(config.configDir, snapshotArg)),
      );
      if (loaded == null) {
        stderr.writeln('Current snapshot not found: $snapshotArg');
        return 1;
      }
      currentSnapshot = loaded.copyWith(
        id: SchemaSnapshot.generateId(),
        prevId: journal.previousId,
      );
    } else {
      currentSnapshot = await SnapshotRunner.build(
        schemaPath: config.schemaPath,
        driver: config.driver,
        configDir: config.configDir,
        prevId: journal.previousId,
      );
    }

    if (!empty && currentSnapshot.tables.isEmpty) {
      stderr.writeln('''
No tables found for "${config.driver}" in schema directory: ${config.schemaPath}''');
      return 1;
    }

    final operations = SchemaDiffer().diff(previousSnapshot, currentSnapshot);

    if (empty) {
      if (operations.isNotEmpty) {
        stderr.writeln(
          'Schema changes are pending, so an empty migration would bury them.\n'
          'Run `raindrop generate` first, then create this one:',
        );
        for (final operation in operations) {
          stderr.writeln('  - ${operation.describe()}');
        }
        return 1;
      }
    } else if (operations.isEmpty) {
      stdout.writeln('No schema changes detected.');
      return 0;
    }

    final migrationIndex = journal.nextIndex;
    final now = DateTime.now();
    final tag = '${migrationTagPrefix(
      naming: config.migrationNaming,
      migrationIndex: migrationIndex,
      at: now,
    )}_${sanitizeMigrationName(migrationName)}';

    final sql = empty
        ? _emptyTemplate(tag)
        : await DdlRunner.generate(
            config.driver,
            operations,
            projectPath: findProjectRoot(config.configDir),
          );

    if (!empty && sql.trim().isEmpty) {
      stdout.writeln('Nothing to migrate: no SQL for the current diff.');
      return 0;
    }

    if (dryRun) {
      stdout
        ..writeln('Would generate migration: $tag.sql')
        ..writeln()
        ..writeln('SQL:')
        ..writeln(sql);
      return 0;
    }

    Directory(config.outPath).createSync(recursive: true);
    Directory(config.metaPath).createSync(recursive: true);

    final migrationPath = p.join(config.outPath, '$tag.sql');
    await File(migrationPath).writeAsString(sql);
    await currentSnapshot.save(config.snapshotPath(migrationIndex));

    final entry = JournalEntry(
      idx: migrationIndex,
      version: SchemaSnapshot.currentVersion,
      when: now.millisecondsSinceEpoch,
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

    if (dartOutputPath != null) {
      await emitDartMigrations(config, updatedJournal, dartOutputPath);
    }

    stdout.writeln('Generated migration: $migrationPath');
    if (dartOutputPath != null) {
      stdout.writeln('Generated Dart migrations file: $dartOutputPath');
    }
    stdout.writeln();
    if (empty) {
      stdout
          .writeln('Write the SQL into that file before it is first applied.');
    } else {
      stdout.writeln('Changes:');
      for (final op in operations) {
        stdout.writeln('  - ${op.describe()}');
      }
    }

    return 0;
  }

  Future<int> _emitOnly(
    RaindropConfig config,
    MigrationJournal journal,
    String? dartOutputPath,
  ) async {
    if (dartOutputPath == null) {
      stderr.writeln(
          'No Dart output path. Set "dart:" in raindrop.yaml or pass --dart.');
      return 1;
    }
    if (journal.entries.isEmpty) {
      stderr.writeln('No migrations in the journal: ${config.journalPath}');
      return 1;
    }

    final missing = [
      for (final entry in journal.entries)
        if (!File(p.join(config.outPath, '${entry.tag}.sql')).existsSync())
          entry.tag,
    ];
    if (missing.isNotEmpty) {
      stderr.writeln(
          'Missing SQL for journalled migrations: ${missing.join(', ')}');
      return 1;
    }

    await emitDartMigrations(config, journal, dartOutputPath);
    stdout
      ..writeln('Generated Dart migrations file: $dartOutputPath')
      ..writeln('Embedded ${journal.entries.length} migration(s).');
    return 0;
  }

  String _emptyTemplate(String tag) => '''
-- $tag
--
-- A hand-written migration. Runs once, in order, inside a transaction, and is
-- checksummed after it is applied: edit it now, never later.
--
-- Nothing here is derived from the schema, so a later `generate` will neither
-- write to this file nor notice if it disagrees with the tables.
''';
}
