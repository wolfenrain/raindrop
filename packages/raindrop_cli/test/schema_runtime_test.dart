import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/runtime/runtime_schema_loader.dart';
import 'package:raindrop_cli/src/runtime/schema_table_discovery.dart';
import 'package:test/test.dart';

/// Package root of `raindrop_cli` (tests run with cwd here).
final _cliPkgRoot = p.normalize(p.absolute(Directory.current.path));

/// Shared temp package: real `pubspec.yaml` + copied schema sources (nested
/// pubspecs under the repo workspace are disallowed, so we materialize this
/// under [Directory.systemTemp]).
Directory? _tempPkg;
late String _tempPkgRoot;
late String _tempLibDir;
late String _tempSchemasFile;

Future<void> _ensureTempFixture() async {
  if (_tempPkg != null) {
    return;
  }
  final raindrop = p.normalize(p.join(_cliPkgRoot, '..', 'raindrop'));
  final sqlite = p.normalize(p.join(_cliPkgRoot, '..', 'raindrop_sqlite'));
  final sourceLib = p.join(
    _cliPkgRoot,
    'test',
    'fixtures',
    'schema_discovery_pkg',
    'lib',
  );

  _tempPkg =
      await Directory.systemTemp.createTemp('raindrop_cli_schema_test_');
  _tempPkgRoot = _tempPkg!.path;
  _tempLibDir = p.join(_tempPkgRoot, 'lib');
  _tempSchemasFile = p.join(_tempLibDir, 'schemas.dart');

  await File(p.join(_tempPkgRoot, 'pubspec.yaml')).writeAsString('''
name: schema_discovery_temp
publish_to: none

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  raindrop:
    path: $raindrop
  raindrop_sqlite:
    path: $sqlite

dependency_overrides:
  raindrop:
    path: $raindrop
''');

  await Directory(_tempLibDir).create(recursive: true);
  await File(p.join(sourceLib, 'schemas.dart')).copy(_tempSchemasFile);

  final pubGet = await Process.run(
    'dart',
    const ['pub', 'get'],
    workingDirectory: _tempPkgRoot,
  );
  expect(pubGet.exitCode, 0, reason: pubGet.stderr.toString());
}

void main() {
  setUpAll(() async {
    await _ensureTempFixture();
  });

  tearDownAll(() async {
    await _tempPkg?.delete(recursive: true);
  });

  group('discoverSchemaVariables', () {
    test('collects tables when static type is a Raindrop Schema subtype',
        () async {
      final found = await discoverSchemaVariables(
        schemaDir: _tempLibDir,
        packageRoot: _tempPkgRoot,
      );

      final names = found.map((e) => e.variableName).toList();
      expect(
        names,
        containsAll(<String>['pets', 'books', 'widgets']),
        reason:
            'Includes sqliteTable, private wrapper, and unrelated factory name',
      );
      expect(names, isNot(contains('notATable')));
      expect(names, isNot(contains('plainConst')));
      expect(names, isNot(contains('lostToDynamic')));
      expect(
        found.where((e) => e.variableName == 'pets').single.filePath,
        _tempSchemasFile,
      );
    });

    test('returns empty for missing schema directory', () async {
      final missing = p.join(_tempPkgRoot, 'lib', '__missing__');
      final found = await discoverSchemaVariables(
        schemaDir: missing,
        packageRoot: _tempPkgRoot,
      );
      expect(found, isEmpty);
    });
  });

  group('RuntimeSchemaLoader', () {
    test('materializes Table columns from the generated runner', () async {
      final snapshot = await RuntimeSchemaLoader.load(
        projectRoot: _tempPkgRoot,
        schemaPath: _tempLibDir,
        dialect: 'sqlite',
        prevId: null,
      );

      expect(
        snapshot.tables.keys,
        containsAll(<String>['pets', 'books', 'widgets']),
      );
      expect(snapshot.tables['pets']?.columns['id']?.type, 'INTEGER');
      expect(snapshot.tables['pets']?.columns['id']?.primaryKey, isTrue);
      expect(snapshot.tables['books']?.columns['title']?.type, 'TEXT');
    });
  });
}
