import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/introspect/snapshot_runner.dart';
import 'package:test/test.dart';

void main() {
  group('SnapshotRunner.packageUri', () {
    final windows = p.Context(style: p.Style.windows);
    final posix = p.Context(style: p.Style.posix);

    test('separates a nested schema with / on Windows', () {
      expect(
        SnapshotRunner.packageUri(
          r'C:\proj\shop\lib\src\schemas\items.dart',
          {'shop': r'C:\proj\shop'},
          context: windows,
        ),
        'package:shop/src/schemas/items.dart',
      );
    });

    test('leaves a schema directly under lib/ alone on Windows', () {
      expect(
        SnapshotRunner.packageUri(
          r'C:\proj\shop\lib\items.dart',
          {'shop': r'C:\proj\shop'},
          context: windows,
        ),
        'package:shop/items.dart',
      );
    });

    test('separates a nested schema with / on POSIX', () {
      expect(
        SnapshotRunner.packageUri(
          '/proj/shop/lib/src/schemas/items.dart',
          {'shop': '/proj/shop'},
          context: posix,
        ),
        'package:shop/src/schemas/items.dart',
      );
    });

    test('skips packages the file is not inside', () {
      expect(
        SnapshotRunner.packageUri(
          '/proj/shop/lib/src/schemas/items.dart',
          {
            'other': '/proj/other',
            'shop': '/proj/shop',
          },
          context: posix,
        ),
        'package:shop/src/schemas/items.dart',
      );
    });

    test('a file outside every package lib/ is a loud error', () {
      expect(
        () => SnapshotRunner.packageUri(
          '/proj/shop/tool/items.dart',
          {'shop': '/proj/shop'},
          context: posix,
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains("is not inside a package's lib/ directory"),
          ),
        ),
      );
    });
  });

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
