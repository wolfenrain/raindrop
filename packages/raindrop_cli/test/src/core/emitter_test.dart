import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/core/config.dart';
import 'package:raindrop_cli/src/core/emitter.dart';
import 'package:raindrop_cli/src/core/journal.dart';
import 'package:test/test.dart';

void main() {
  late Directory temp;
  late RaindropConfig config;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('raindrop_emitter');
    Directory(p.join(temp.path, 'migrations')).createSync(recursive: true);
    config = RaindropConfig(
      schemaPath: p.join(temp.path, 'schema'),
      outPath: p.join(temp.path, 'migrations'),
      configDir: temp.path,
      driver: 'raindrop_sqlite',
    );
  });

  tearDown(() {
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException catch (_) {}
  });

  void writeSql(String tag, String sql) =>
      File(p.join(config.outPath, '$tag.sql')).writeAsStringSync(sql);

  MigrationJournal journalOf(List<String> tags) => MigrationJournal(
        version: MigrationJournal.currentVersion,
        dialect: 'sqlite',
        entries: [
          for (var i = 0; i < tags.length; i++)
            JournalEntry(
              idx: i,
              version: '1',
              when: i,
              tag: tags[i],
              snapshotId: 'snap-$i',
            ),
        ],
      );

  Future<String> emit(List<String> tags) async {
    final out = p.join(temp.path, 'migrations.dart');
    await emitDartMigrations(config, journalOf(tags), out);
    return File(out).readAsStringSync();
  }

  group('emitDartMigrations', () {
    test('embeds every journalled migration in order', () async {
      writeSql('0000_schema', 'CREATE TABLE "a" (id INTEGER);');
      writeSql('0001_seed', 'INSERT INTO "a" (id) VALUES (1);');

      final dart = await emit(['0000_schema', '0001_seed']);

      expect(dart.indexOf('0000_schema'), lessThan(dart.indexOf('0001_seed')));
      expect(dart, contains('CREATE TABLE "a"'));
      expect(dart, contains('INSERT INTO "a"'));
    });

    test('embeds SQL verbatim, comments and all', () async {
      final sql =
          '-- 0001_seed\n--\n-- notes\nINSERT INTO "a" (id) VALUES (1);';
      writeSql('0001_seed', sql);

      expect(await emit(['0001_seed']), contains(sql));
    });

    test('escapes a triple quote so it cannot close the literal', () async {
      writeSql('0001_seed', "INSERT INTO \"a\" (v) VALUES ('''');");

      final dart = await emit(['0001_seed']);
      expect(dart, contains(r"\'''"));
    });

    test('an empty journal emits an empty list', () async {
      final dart = await emit([]);
      expect(dart, contains('final migrations = ['));
      expect(dart, contains('];'));
      expect(dart, isNot(contains('Migration')));
    });
  });

  group('sanitizeMigrationName', () {
    test('creates the Dart output directory when absent', () async {
      writeSql('0000_init', 'CREATE TABLE a (id INTEGER);');
      final nested = p.join(temp.path, 'deep', 'nested', 'migrations.dart');

      await emitDartMigrations(config, journalOf(['0000_init']), nested);

      expect(File(nested).existsSync(), isTrue);
    });

    test('lowercases and collapses separators', () {
      expect(sanitizeMigrationName('Seed Console'), 'seed_console');
      expect(sanitizeMigrationName('add--column'), 'add_column');
      expect(sanitizeMigrationName('Fix/Bug #12'), 'fix_bug_12');
    });

    test('leaves an already-clean name alone', () {
      expect(sanitizeMigrationName('seed_console'), 'seed_console');
    });
  });

  group('findProjectRoot', () {
    test('walks up to the nearest pubspec', () {
      expect(
        findProjectRoot(p.join(Directory.current.path, 'lib', 'src')),
        Directory.current.path,
      );
    });

    test('falls back to the start when no pubspec exists above', () {
      final orphan = Directory.systemTemp.createTempSync('raindrop_orphan');
      addTearDown(() => orphan.deleteSync(recursive: true));

      expect(findProjectRoot(orphan.path), orphan.path);
    });
  });
}
