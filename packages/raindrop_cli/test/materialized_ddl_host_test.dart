import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop/ddl.dart';
import 'package:raindrop_cli/src/core/package_paths.dart';
import 'package:test/test.dart';

import 'support/raindrop_test_packages.dart';

void main() {
  group('materialized ddl subprocess host', () {
    late Directory projectRoot;
    late RaindropTestPackages packages;

    setUp(() async {
      if (!Platform.resolvedExecutable.toLowerCase().contains('dart')) {
        return;
      }

      packages = RaindropTestPackages.load();

      projectRoot = Directory.systemTemp.createTempSync('raindrop_cli_e2e_');
      addTearDown(() => projectRoot.deleteSync(recursive: true));

      await _bootstrapProjectWithoutRaindropCli(
        projectRoot: projectRoot,
        raindropRoot: packages.raindrop,
        raindropSqliteRoot: packages.raindropSqlite,
      );
    });

    test('package_config omits raindrop_cli', () {
      if (!Platform.resolvedExecutable.toLowerCase().contains('dart')) {
        return;
      }

      final config = jsonDecode(
        File(p.join(projectRoot.path, '.dart_tool', 'package_config.json'))
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      final names = (config['packages'] as List<dynamic>)
          .map((pkg) => (pkg as Map<String, dynamic>)['name'] as String);

      expect(names, contains('raindrop'));
      expect(names, contains('raindrop_sqlite'));
      expect(names, isNot(contains('raindrop_cli')));
    });

    test('materializes host script when raindrop_cli is absent', () async {
      if (!Platform.resolvedExecutable.toLowerCase().contains('dart')) {
        return;
      }

      final host = await RaindropPackagePaths.packageFile(
        packageName: 'raindrop_cli',
        relativePath: 'lib/src/ddl/ddl_subprocess_host.dart',
        projectPath: projectRoot.path,
      );

      expect(host, isNotNull);
      expect(
        host!.path,
        p.join(projectRoot.path, '.dart_tool', 'raindrop', 'ddl_subprocess_host.dart'),
      );
      expect(host.existsSync(), isTrue);
      expect(host.readAsStringSync(), contains('Isolate.spawnUri'));
    });

    test('materialized host generates sqlite DDL via dart subprocess', () async {
      if (!Platform.resolvedExecutable.toLowerCase().contains('dart')) {
        return;
      }

      final host = await RaindropPackagePaths.packageFile(
        packageName: 'raindrop_cli',
        relativePath: 'lib/src/ddl/ddl_subprocess_host.dart',
        projectPath: projectRoot.path,
      );
      expect(host, isNotNull);

      final packageConfig =
          p.join(projectRoot.path, '.dart_tool', 'package_config.json');
      final sqliteDdl =
          p.join(packages.raindropSqlite, 'lib', 'src', 'sqlite_ddl.dart');
      final messageFile = File(
        p.join(projectRoot.path, '.dart_tool', 'raindrop', 'ddl_message.json'),
      )..writeAsStringSync(
          jsonEncode({
            'action': 'generate',
            'operations': [
              const CreateTable(
                tableName: 'items',
                columns: [
                  ColumnInfo(
                    name: 'id',
                    type: 'INTEGER',
                    isNullable: false,
                    primaryKey: true,
                    autoIncrement: true,
                  ),
                  ColumnInfo(
                    name: 'name',
                    type: 'TEXT',
                    isNullable: false,
                  ),
                ],
              ).toMap(),
            ],
          }),
        );

      final result = await Process.run(
        Platform.resolvedExecutable,
        [
          host!.path,
          sqliteDdl,
          '--packages=$packageConfig',
          '--message-file=${messageFile.path}',
        ],
        workingDirectory: projectRoot.path,
      );

      expect(result.exitCode, 0, reason: '${result.stderr}\n${result.stdout}');

      final response =
          jsonDecode('${result.stdout}'.trim()) as Map<String, dynamic>;
      expect(response['success'], isTrue);
      expect(response['sql'], contains('CREATE TABLE "items"'));
      expect(response['sql'], contains('"name" TEXT NOT NULL'));
    });
  });
}

Future<void> _bootstrapProjectWithoutRaindropCli({
  required Directory projectRoot,
  required String raindropRoot,
  required String raindropSqliteRoot,
}) async {
  File(p.join(projectRoot.path, 'pubspec.yaml')).writeAsStringSync('''
name: materialized_ddl_host_fixture
publish_to: none

environment:
  sdk: ">=3.12.0 <4.0.0"

dependencies:
  raindrop:
    path: ${jsonEncode(raindropRoot)}
  raindrop_sqlite:
    path: ${jsonEncode(raindropSqliteRoot)}

dependency_overrides:
  raindrop:
    path: ${jsonEncode(raindropRoot)}
''');

  final pubGet = await Process.run(
    Platform.resolvedExecutable,
    const ['pub', 'get'],
    workingDirectory: projectRoot.path,
  );
  if (pubGet.exitCode != 0) {
    throw StateError(
      'dart pub get failed:\n${pubGet.stderr}\n${pubGet.stdout}',
    );
  }
}
