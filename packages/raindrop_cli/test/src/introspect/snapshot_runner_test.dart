import 'dart:io';

import 'package:raindrop_cli/src/introspect/snapshot_runner.dart';
import 'package:test/test.dart';

void main() {
  group('SnapshotRunner.build', () {
    test('a missing package_config is a loud error', () async {
      final orphan = Directory.systemTemp.createTempSync('raindrop_orphan');
      addTearDown(() => orphan.deleteSync(recursive: true));

      await expectLater(
        SnapshotRunner.build(
          schemaPath: orphan.path,
          driver: 'raindrop_sqlite',
          configDir: orphan.path,
        ),
        throwsStateError,
      );
    });

    test('an unresolved driver package is a loud error', () async {
      final schemas = Directory.systemTemp.createTempSync('raindrop_schemas');
      addTearDown(() => schemas.deleteSync(recursive: true));

      await expectLater(
        SnapshotRunner.build(
          schemaPath: schemas.path,
          driver: 'no_such_driver',
          configDir: Directory.current.path,
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('"no_such_driver"'),
          ),
        ),
      );
    });
  });
}
