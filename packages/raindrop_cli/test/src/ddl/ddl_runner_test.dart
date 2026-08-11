import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop/ddl.dart';
import 'package:raindrop_cli/src/ddl/ddl_runner.dart';
import 'package:test/test.dart';

void main() {
  group('DdlRunner.generate', () {
    test('resolves the driver and generates through its entrypoint', () async {
      final sql = await DdlRunner.generate(
        'raindrop_sqlite',
        [DropTable('ghosts')],
        projectPath: Directory.current.path,
      );

      expect(sql, contains('DROP TABLE "ghosts";'));
    });

    test('a generator failure travels back as an error', () async {
      AlterTable typeChange(String table, {List<ReferencedBy>? referencedBy}) {
        ColumnInfo column(String type) =>
            ColumnInfo(name: 'a', type: type, isNullable: false);
        return AlterTable(
          oldTable: TableInfo(name: table, columns: [column('TEXT')]),
          newTable: TableInfo(name: table, columns: [column('INTEGER')]),
          referencedBy: referencedBy ?? const [],
        );
      }

      await expectLater(
        DdlRunner.generate(
          'raindrop_sqlite',
          [
            typeChange(
              'users',
              referencedBy: [
                ReferencedBy(
                  table: TableInfo(
                    name: 'pets',
                    columns: [
                      ColumnInfo(
                        name: 'owner_id',
                        type: 'INTEGER',
                        isNullable: false,
                        foreignKey: ForeignKeyInfo(
                          referencedTable: 'users',
                          referencedColumn: 'a',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            typeChange('pets'),
          ],
          projectPath: Directory.current.path,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => '$e',
            'message',
            contains('DDL operation failed'),
          ),
        ),
      );
    });

    test('an unknown driver package is a loud error', () async {
      await expectLater(
        DdlRunner.generate(
          'no_such_driver',
          [],
          projectPath: Directory.current.path,
        ),
        throwsArgumentError,
      );
    });

    test('a missing package_config is a loud error', () async {
      final orphan = Directory.systemTemp.createTempSync('raindrop_orphan');
      addTearDown(() => orphan.deleteSync(recursive: true));

      await expectLater(
        DdlRunner.generate('raindrop_sqlite', [], projectPath: orphan.path),
        throwsStateError,
      );
    });
  });

  group('DdlRunner.resolveDriverPackage', () {
    late Directory fixture;

    setUp(() {
      fixture = Directory.systemTemp.createTempSync('raindrop_cli_resolve');
      File(p.join(fixture.path, '.dart_tool', 'package_config.json'))
        ..createSync(recursive: true)
        ..writeAsStringSync(
          jsonEncode({
            'configVersion': 2,
            'packages': [
              {
                'name': 'raindrop_sqlite',
                'rootUri': '../drivers/raindrop_sqlite',
                'packageUri': 'lib/',
              },
              {
                'name': 'sqlite',
                'rootUri': '../drivers/sqlite',
                'packageUri': 'lib/',
              },
              {
                'name': 'my_custom_sqlite',
                'rootUri': '../drivers/my_custom_sqlite',
                'packageUri': 'lib/',
              },
            ],
          }),
        );
    });

    tearDown(() => fixture.deleteSync(recursive: true));

    test('resolves a first-party driver by its exact package name', () async {
      final uri = await DdlRunner.resolveDriverPackage(
        'raindrop_sqlite',
        fixture.path,
      );

      expect('$uri', endsWith('drivers/raindrop_sqlite'));
    });

    test('resolves a custom driver by its exact package name', () async {
      final uri = await DdlRunner.resolveDriverPackage(
        'my_custom_sqlite',
        fixture.path,
      );

      expect('$uri', endsWith('drivers/my_custom_sqlite'));
    });

    test('returns null for an unknown package', () async {
      expect(
        await DdlRunner.resolveDriverPackage('unknown', fixture.path),
        isNull,
      );
    });
  });
}
