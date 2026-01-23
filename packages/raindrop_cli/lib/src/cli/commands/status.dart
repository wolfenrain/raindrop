import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:raindrop_cli/src/core/config.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/journal.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:raindrop_cli/src/parser/schema_parser.dart';

/// Command to show migration status.
class StatusCommand extends Command<int> {
  @override
  String get name => 'status';

  @override
  String get description => 'Show the status of schemas and migrations.';

  @override
  Future<int> run() async {
    final configPath = globalResults!['config'] as String;

    // Load configuration
    final config = await RaindropConfig.load(configPath);

    print('Configuration:');
    print('  Schema path: ${config.schemaPath}');
    print('  Output path: ${config.outPath}');
    print('  Meta path: ${config.metaPath}');
    print('  Dialect: ${config.dialect}');
    print('');

    // Load the journal
    final journal = await MigrationJournal.load(
      config.journalPath,
      config.dialect,
    );

    // Parse current schema
    final parser = SchemaParser();
    final currentSnapshot = await parser.parseDirectory(
      config.schemaPath,
      dialect: config.dialect,
      prevId: journal.previousId,
    );

    print('Current schema:');
    if (currentSnapshot.tables.isEmpty) {
      print('  No tables found.');
    } else {
      print('  Dialect: ${currentSnapshot.dialect}');
      print('  Tables: ${currentSnapshot.tables.length}');
      for (final table in currentSnapshot.tables.values) {
        print('    - ${table.name} (${table.columns.length} columns)');
      }
    }
    print('');

    // Load previous snapshot if it exists
    SchemaSnapshot? previousSnapshot;
    if (journal.entries.isNotEmpty) {
      final lastEntry = journal.entries.last;
      final snapshotPath = config.snapshotPath(lastEntry.idx);
      previousSnapshot = await SchemaSnapshot.load(snapshotPath);

      // Calculate diff
      final differ = SchemaDiffer();
      final operations = differ.diff(previousSnapshot, currentSnapshot);

      if (operations.isEmpty) {
        print('Schema is up to date with latest snapshot.');
      } else {
        print('Pending changes:');
        for (final op in operations) {
          print('  - ${op.describe()}');
        }
      }
    } else {
      print(
          'No snapshots found. Run "raindrop generate" to create initial migration.');
    }
    print('');

    // Show journal entries
    print('Migration journal:');
    if (journal.entries.isEmpty) {
      print('  No migrations recorded.');
    } else {
      print('  Version: ${journal.version}');
      print('  Dialect: ${journal.dialect}');
      print('  Entries: ${journal.entries.length}');
      for (final entry in journal.entries) {
        final date = DateTime.fromMillisecondsSinceEpoch(entry.when);
        print('    ${entry.idx}: ${entry.tag} (${date.toIso8601String()})');
      }
    }
    print('');

    // List existing migration files
    final migrationsDir = Directory(config.outPath);
    if (migrationsDir.existsSync()) {
      final migrations = migrationsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.sql'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      print('Migration files:');
      if (migrations.isEmpty) {
        print('  No migration files found.');
      } else {
        for (final migration in migrations) {
          print('  - ${p.basename(migration.path)}');
        }
      }
    } else {
      print('Migrations directory does not exist.');
    }

    return 0;
  }
}
