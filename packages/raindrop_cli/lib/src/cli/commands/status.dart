import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/config.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/journal.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:raindrop_cli/src/introspect/snapshot_runner.dart';

/// Command to show migration status.
class StatusCommand extends Command<int> {
  @override
  String get name => 'status';

  @override
  String get description => 'Show the status of schemas and migrations.';

  @override
  Future<int> run() async {
    // Load configuration
    final config = await RaindropConfig.loadResolved(globalResults!);

    stdout
      ..writeln('Configuration:')
      ..writeln('  Schema path: ${config.schemaPath}')
      ..writeln('  Output path: ${config.outPath}')
      ..writeln('  Meta path: ${config.metaPath}')
      ..writeln('  Driver: ${config.driver}')
      ..writeln('  Dart output: ${config.dartPath ?? 'not configured'}')
      ..writeln('  Migration naming: ${config.migrationNaming.name}')
      ..writeln();

    // Load the journal
    final journal = await MigrationJournal.load(config.journalPath);

    final currentSnapshot = await SnapshotRunner.build(
      schemaPath: config.schemaPath,
      driver: config.driver,
      configDir: config.configDir,
      prevId: journal.previousId,
    );

    stdout.writeln('Current schema:');
    if (currentSnapshot.schema.tables.isEmpty) {
      stdout.writeln('  No tables found.');
    } else {
      stdout
        ..writeln('  Dialect: ${currentSnapshot.dialect}')
        ..writeln('  Tables: ${currentSnapshot.schema.tables.length}');
      for (final table in currentSnapshot.schema.tables.values) {
        stdout.writeln('    - ${table.name} (${table.columns.length} columns)');
      }
    }
    stdout.writeln();

    // Load previous snapshot if it exists
    MigrationSnapshot? previousSnapshot;
    if (journal.entries.isNotEmpty) {
      final lastEntry = journal.entries.last;
      final snapshotPath = config.snapshotPath(lastEntry.idx);
      previousSnapshot = await MigrationSnapshot.load(snapshotPath);

      // Calculate diff
      final differ = SchemaDiffer();
      final operations = differ.diff(
        previousSnapshot?.schema,
        currentSnapshot.schema,
      );

      if (operations.isEmpty) {
        stdout.writeln('Schema is up to date with latest snapshot.');
      } else {
        stdout.writeln('Pending changes:');
        for (final op in operations) {
          stdout.writeln('  - ${op.describe()}');
        }
      }
    } else {
      stdout.writeln(
        '''
No snapshots found. Run "raindrop generate" to create initial migration.''',
      );
    }
    stdout
      ..writeln()
      // Show journal entries
      ..writeln('Migration journal:');
    if (journal.entries.isEmpty) {
      stdout.writeln('  No migrations recorded.');
    } else {
      stdout
        ..writeln('  Version: ${journal.version}')
        ..writeln('  Dialect: ${journal.dialect}')
        ..writeln('  Entries: ${journal.entries.length}');
      for (final entry in journal.entries) {
        final date = DateTime.fromMillisecondsSinceEpoch(entry.when);
        stdout.writeln(
            '    ${entry.idx}: ${entry.tag} (${date.toIso8601String()})');
      }
    }
    stdout.writeln();

    // List existing migration files
    final migrationsDir = Directory(config.outPath);
    if (migrationsDir.existsSync()) {
      final migrations = migrationsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      stdout.writeln('Migration files:');
      if (migrations.isEmpty) {
        stdout.writeln('  No migration files found.');
      } else {
        for (final migration in migrations) {
          stdout.writeln('  - ${p.basename(migration.path)}');
        }
      }
    } else {
      stdout.writeln('Migrations directory does not exist.');
    }

    return 0;
  }
}
