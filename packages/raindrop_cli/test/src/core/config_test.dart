import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/raindrop_cli.dart';
import 'package:test/test.dart';

void main() {
  group('RaindropConfig', () {
    test('load resolves paths relative to the config file', () async {
      final dir = Directory.systemTemp.createTempSync('config_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'raindrop.yaml');
      File(path).writeAsStringSync('''
driver: raindrop_sqlite
schemas: lib/src
out: db/migrations
dart: lib/migrations.dart
migration_naming: timestamp
''');

      final config = await RaindropConfig.load(path);
      expect(config.driver, 'raindrop_sqlite');
      expect(config.schemaPath, p.join(dir.path, 'lib', 'src'));
      expect(config.outPath, p.join(dir.path, 'db', 'migrations'));
      expect(config.dartPath, p.join(dir.path, 'lib', 'migrations.dart'));
      expect(config.migrationNaming, MigrationNaming.timestamp);
      expect(config.metaPath, p.join(dir.path, 'db', 'migrations', 'meta'));
      expect(
        config.snapshotPath(3),
        p.join(dir.path, 'db', 'migrations', 'meta', '0003_snapshot.json'),
      );
    });

    test('a missing driver is a loud error', () async {
      final dir = Directory.systemTemp.createTempSync('config_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'raindrop.yaml');
      File(path).writeAsStringSync('schemas: lib');

      expect(() => RaindropConfig.load(path), throwsStateError);
    });

    test('a legacy dialect key is a loud error naming driver', () async {
      final dir = Directory.systemTemp.createTempSync('config_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'raindrop.yaml');
      File(path).writeAsStringSync('dialect: sqlite\nschemas: lib');

      expect(
        () => RaindropConfig.load(path),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('"driver"'),
          ),
        ),
      );
    });

    test('a missing file is a loud error', () {
      expect(() => RaindropConfig.load('/nowhere.yaml'), throwsStateError);
    });

    test('an invalid migration_naming is a loud error', () async {
      final dir = Directory.systemTemp.createTempSync('config_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'raindrop.yaml');
      File(path).writeAsStringSync(
          'driver: raindrop_sqlite\nmigration_naming: bogus');

      expect(() => RaindropConfig.load(path), throwsStateError);
    });

    test('tag prefixes are stable-width', () {
      expect(
        migrationTagPrefix(
          naming: MigrationNaming.integer,
          migrationIndex: 7,
          at: DateTime(2026),
        ),
        '0007',
      );
      expect(
        migrationTagPrefix(
          naming: MigrationNaming.timestamp,
          migrationIndex: 7,
          at: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        ),
        '001700000000000',
      );
    });
  });
}
