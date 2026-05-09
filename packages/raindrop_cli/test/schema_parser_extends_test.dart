import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/raindrop_cli.dart';
import 'package:test/test.dart';

final _raindropCliRoot = _resolveRaindropCliPackageRoot();

String _resolveRaindropCliPackageRoot() {
  final resolved = Isolate.resolvePackageUriSync(
    Uri.parse('package:raindrop_cli/raindrop_cli.dart'),
  );
  if (resolved == null) {
    throw StateError(
      'Could not resolve package:raindrop_cli/raindrop_cli.dart '
      '(set up pub get / package config).',
    );
  }
  return p.canonicalize(p.join(p.dirname(resolved.toFilePath()), '..'));
}

final _packagesRoot = p.normalize(p.join(_raindropCliRoot, '..'));

/// Integration tests for schema parsing when a row type [extends] another
/// schema class (transitive [Schema] inheritance).
void main() {
  group('SchemaParser transitive extends', () {
    late String raindropPkg;
    late String raindropSqlitePkg;

    setUpAll(() {
      raindropPkg = p.join(_packagesRoot, 'raindrop');
      raindropSqlitePkg = p.join(_packagesRoot, 'raindrop_sqlite');
      expect(Directory(raindropPkg).existsSync(), isTrue);
      expect(Directory(raindropSqlitePkg).existsSync(), isTrue);
    });

    test('merges columns from intermediate schema superclass (Auth → User)',
        () async {
      final fixture = await _bootstrapMiniPackage('merges_auth_user', '''
name: schema_fixture_merges_auth_user
publish_to: none
environment:
  sdk: ">=3.5.0 <4.0.0"
dependencies:
  raindrop_sqlite:
    path: ${_yamlPath(raindropSqlitePkg)}
dependency_overrides:
  raindrop:
    path: ${_yamlPath(raindropPkg)}
''', {
        p.join('lib', 'schemas', 'auth.dart'): r'''
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

abstract base class Auth<T extends Auth<T>> extends Schema<T> {
  Auth({
    required String email,
    required String password,
    required SchemaBuilder<T> $,
  })  : email = $.text('email', (s) => s.email, email),
        password = $.text('password', (s) => s.password, password);

  final TextColumn email;
  final TextColumn password;
}
''',
        p.join('lib', 'schemas', 'user.dart'): r'''
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

import 'auth.dart';

final class User extends Auth<User> {
  User({
    required String name,
    required String email,
    required String password,
  })  : name = $.text('name', (s) => s.name, name),
        super(email: email, password: password, $: $);

  final TextColumn name;

  static const $ = SchemaBuilder<User>();
}

final users = sqliteTable(
  'users',
  () => User(
    name: fakes.text(),
    email: fakes.text(),
    password: fakes.text(),
  ),
);
''',
      });

      addTearDown(fixture.delete);

      final snapshot = await SchemaParser().parseDirectory(
        fixture.schemasDir,
        dialect: 'sqlite',
      );

      expect(snapshot.tables.containsKey('users'), isTrue);
      final cols = snapshot.tables['users']!.columns;
      expect(cols.keys, contains('email'));
      expect(cols.keys, contains('password'));
      expect(cols.keys, contains('name'));
      expect(cols['email']!.type, 'TEXT');
      expect(cols['password']!.type, 'TEXT');
      expect(cols['name']!.type, 'TEXT');
    });

    test('direct Schema subclass still parses (regression)', () async {
      final fixture = await _bootstrapMiniPackage('direct_schema', '''
name: schema_fixture_direct
publish_to: none
environment:
  sdk: ">=3.5.0 <4.0.0"
dependencies:
  raindrop_sqlite:
    path: ${_yamlPath(raindropSqlitePkg)}
dependency_overrides:
  raindrop:
    path: ${_yamlPath(raindropPkg)}
''', {
        p.join('lib', 'schemas', 'pet.dart'): r'''
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class Pet extends Schema<Pet> {
  Pet({required String tag})
      : tag = $.text('tag', (s) => s.tag, tag);

  final TextColumn tag;

  static const $ = SchemaBuilder<Pet>();
}

final pets = sqliteTable(
  'pets',
  () => Pet(tag: fakes.text()),
);
''',
      });

      addTearDown(fixture.delete);

      final snapshot = await SchemaParser().parseDirectory(
        fixture.schemasDir,
        dialect: 'sqlite',
      );

      expect(snapshot.tables.containsKey('pets'), isTrue);
      final cols = snapshot.tables['pets']!.columns;
      expect(cols.keys, equals(['tag']));
      expect(cols['tag']!.type, 'TEXT');
    });
  });
}

String _yamlPath(String absolute) => absolute.replaceAll(r'\', '/');

class _Fixture {
  _Fixture({required this.root, required this.schemasDir, required this.delete});

  final String root;
  final String schemasDir;
  final void Function() delete;
}

Future<_Fixture> _bootstrapMiniPackage(
  String uniqueName,
  String pubspecYaml,
  Map<String, String> relativePathToContent,
) async {
  final tmp = await Directory.systemTemp.createTemp('raindrop_cli_$uniqueName');
  File(p.join(tmp.path, 'pubspec.yaml')).writeAsStringSync(pubspecYaml.trim());
  for (final entry in relativePathToContent.entries) {
    final file = File(p.join(tmp.path, entry.key));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value.trim());
  }

  final pubGet = await Process.run(
    Platform.resolvedExecutable,
    ['pub', 'get'],
    workingDirectory: tmp.path,
    environment: {...Platform.environment},
  );
  expect(
    pubGet.exitCode,
    0,
    reason:
        'pub get failed:\n${pubGet.stdout}\n${pubGet.stderr}\n${tmp.path}',
  );

  final schemas = p.join(tmp.path, 'lib', 'schemas');
  return _Fixture(
    root: tmp.path,
    schemasDir: schemas,
    delete: () {
      if (tmp.existsSync()) {
        tmp.deleteSync(recursive: true);
      }
    },
  );
}
