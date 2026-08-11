import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/cli/cli_runner.dart';
import 'package:raindrop_cli/src/ddl/ddl_runner.dart';
import 'package:test/test.dart';

void main() {
  late Directory fixture;
  late String config;

  String schemaSource({bool withEmail = false}) => '''
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class Owner {
  Owner({required this.name, this.id, this.email});
  final int? id;
  final String name;
  final String? email;
}

class OwnerSchema extends Schema<Owner> {
  OwnerSchema(super.\$)
      : id = \$.integer('id', (o) => o.id).primaryKey(autoIncrement: true),
        name = \$.text('name', (o) => o.name)${withEmail ? r'''
,
        email = $.text('email', (o) => o.email)''' : ''};

  final ColumnType<int?> id;
  final ColumnType<String> name;${withEmail ? '''
  final ColumnType<String?> email;''' : ''}

  @override
  Owner fromRow(RowReader read) => Owner(
        id: read(id),
        name: read(name)!,${withEmail ? '''
        email: read(email),''' : ''}
      );
}

final owners = sqliteTable('owners', OwnerSchema.new, (t) {
  index('owners_name').on(t.name);
  check('owners_named', length(t.name).greaterThan(0)).on(t);
});

class Pet {
  Pet({required this.ownerId, this.id});
  final int? id;
  final int ownerId;
}

class PetSchema extends Schema<Pet> {
  PetSchema(super.\$)
      : id = \$.integer('id', (x) => x.id).primaryKey(autoIncrement: true),
        ownerId = \$.integer('owner_id', (x) => x.ownerId)
            .references(() => owners.id, onDelete: ReferentialAction.cascade);

  final ColumnType<int?> id;
  final ColumnType<int> ownerId;

  @override
  Pet fromRow(RowReader read) => Pet(id: read(id), ownerId: read(ownerId)!);
}

final pets = sqliteTable('pets', PetSchema.new);
''';

  setUpAll(() async {
    fixture = Directory.systemTemp.createTempSync('raindrop_cli_e2e_');
    final packages = p.normalize(
      p.join(Directory.current.path, '..'),
    );

    File(p.join(fixture.path, 'pubspec.yaml')).writeAsStringSync('''
name: fixture_schema

environment:
  sdk: ^3.5.0

dependencies:
  raindrop:
    path: $packages/raindrop
  raindrop_sqlite:
    path: $packages/raindrop_sqlite
  broken_driver:
    path: broken_driver
  blank_driver:
    path: blank_driver

dependency_overrides:
  raindrop:
    path: $packages/raindrop
  raindrop_sqlite:
    path: $packages/raindrop_sqlite
''');
    Directory(p.join(fixture.path, 'lib')).createSync();
    File(p.join(fixture.path, 'lib', 'schema.dart'))
        .writeAsStringSync(schemaSource());
    config = p.join(fixture.path, 'raindrop.yaml');
    File(config).writeAsStringSync('''
driver: raindrop_sqlite
schemas: lib
out: migrations
dart: lib/migrations.dart
''');

    // A driver whose entrypoint compiles but dies during load, before it
    // can send its command port: the load race's test double.
    Directory(p.join(fixture.path, 'broken_driver', 'lib'))
        .createSync(recursive: true);
    File(p.join(fixture.path, 'broken_driver', 'pubspec.yaml'))
        .writeAsStringSync('''
name: broken_driver
environment:
  sdk: ^3.6.0
''');
    File(p.join(fixture.path, 'broken_driver', 'lib', 'ddl.dart'))
        .writeAsStringSync('''
import 'dart:isolate';

void main(List<String> args, SendPort sendPort) {
  throw StateError('exploded during load');
}
''');

    // A third-party driver that speaks the protocol but renders no SQL.
    Directory(p.join(fixture.path, 'blank_driver', 'lib'))
        .createSync(recursive: true);
    File(p.join(fixture.path, 'blank_driver', 'pubspec.yaml'))
        .writeAsStringSync('''
name: blank_driver
environment:
  sdk: ^3.6.0
dependencies:
  raindrop:
    path: $packages/raindrop
  raindrop_sqlite:
    path: $packages/raindrop_sqlite
''');
    File(p.join(fixture.path, 'blank_driver', 'lib', 'blank_driver.dart'))
        .writeAsStringSync('''
export 'package:raindrop_sqlite/raindrop_sqlite.dart';
''');
    File(p.join(fixture.path, 'blank_driver', 'lib', 'ddl.dart'))
        .writeAsStringSync('''
import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

void main(List<String> args, SendPort sendPort) =>
    serveDdlGenerator(const BlankDdlGenerator(), sendPort);

class BlankDdlGenerator extends DdlGenerator {
  const BlankDdlGenerator() : super(dialect: const SQLiteDialect());

  @override
  String generate(List<DiffOperation> operations) => '   ';

  @override
  String createTable(TableInfo table) => '';
  @override
  String dropTable(String tableName) => '';
  @override
  String alterTable(AlterTable operation) => '';
  @override
  String createIndex(IndexInfo index) => '';
  @override
  String dropIndex(String indexName) => '';
  @override
  String getColumnType(ColumnInfo column) => column.type;
}
''');

    final resolved = Process.runSync(
      'dart',
      ['pub', 'get'],
      workingDirectory: fixture.path,
    );
    expect(resolved.exitCode, 0, reason: '${resolved.stderr}');
  });

  tearDownAll(() => fixture.deleteSync(recursive: true));

  File migration(String name) => File(p.join(fixture.path, 'migrations', name));

  test('--version exits cleanly', () async {
    expect(await CliRunner().run(['--version']), 0);
  });

  test('generate requires a name', () async {
    expect(await CliRunner().run(['-c', config, 'generate']), 1);
  });

  test('status before any migration reports an empty world', () async {
    expect(await CliRunner().run(['-c', config, 'status']), 0);
  });

  test('the first generate creates tables, indexes, journal and Dart file',
      () async {
    expect(await CliRunner().run(['-c', config, 'generate', '-n', 'init']), 0);

    final sql = migration('0000_init.sql').readAsStringSync();
    expect(sql, contains('CREATE TABLE "owners"'));
    expect(sql, contains('CONSTRAINT "owners_named" CHECK'));
    expect(sql, contains('REFERENCES "owners"("id") ON DELETE CASCADE'));
    expect(sql, contains('CREATE INDEX "owners_name"'));

    final journal = File(
      p.join(fixture.path, 'migrations', 'meta', '_journal.json'),
    );
    expect(journal.existsSync(), isTrue);
    expect(
      File(p.join(fixture.path, 'migrations', 'meta', '0000_snapshot.json'))
          .existsSync(),
      isTrue,
    );
    expect(
      File(p.join(fixture.path, 'lib', 'migrations.dart')).readAsStringSync(),
      contains("Migration('0000_init'"),
    );
  });

  test('an unchanged schema generates nothing', () async {
    expect(await CliRunner().run(['-c', config, 'generate', '-n', 'noop']), 0);
    expect(migration('0001_noop.sql').existsSync(), isFalse);
  });

  test('an empty migration is refused while changes are pending', () async {
    File(p.join(fixture.path, 'lib', 'schema.dart'))
        .writeAsStringSync(schemaSource(withEmail: true));

    expect(
      await CliRunner()
          .run(['-c', config, 'generate', '--empty', '-n', 'nope']),
      1,
    );
  });

  test('status reports the pending change', () async {
    expect(await CliRunner().run(['-c', config, 'status']), 0);
  });

  test('a schema change becomes an ALTER migration', () async {
    expect(
      await CliRunner()
          .run(['-c', config, 'generate', '--dry-run', '-n', 'email']),
      0,
    );
    expect(migration('0001_email.sql').existsSync(), isFalse,
        reason: 'dry-run must write nothing');

    expect(await CliRunner().run(['-c', config, 'generate', '-n', 'email']), 0);
    final sql = migration('0001_email.sql').readAsStringSync();
    expect(sql, contains('ALTER TABLE "owners" ADD COLUMN "email" TEXT;'));
  });

  test('status is clean again, and an empty migration is now allowed',
      () async {
    expect(await CliRunner().run(['-c', config, 'status']), 0);
    expect(
      await CliRunner()
          .run(['-c', config, 'generate', '--empty', '-n', 'seeds']),
      0,
    );
    expect(
      migration('0002_seeds.sql').readAsStringSync(),
      contains('hand-written migration'),
    );
  });

  test('--dart-only re-emits the embedded file from the journal', () async {
    final dartFile = File(p.join(fixture.path, 'lib', 'migrations.dart'))
      ..deleteSync();

    expect(
      await CliRunner().run(['-c', config, 'generate', '--dart-only']),
      0,
    );
    final emitted = dartFile.readAsStringSync();
    expect(emitted, contains("Migration('0000_init'"));
    expect(emitted, contains("Migration('0001_email'"));
    expect(emitted, contains("Migration('0002_seeds'"));
  });

  test('--dart-only refuses when a journalled .sql file is missing', () async {
    final moved = migration('0002_seeds.sql');
    final backup = moved.readAsStringSync();
    moved.deleteSync();

    expect(
      await CliRunner().run(['-c', config, 'generate', '--dart-only']),
      1,
    );

    migration('0002_seeds.sql').writeAsStringSync(backup);
  });

  test('an empty schema directory has no tables to report or migrate',
      () async {
    Directory(p.join(fixture.path, 'empty_schemas')).createSync();
    final emptyConfig = p.join(fixture.path, 'raindrop_empty.yaml');
    File(emptyConfig).writeAsStringSync('''
driver: raindrop_sqlite
schemas: empty_schemas
out: empty_migrations
''');

    expect(await CliRunner().run(['-c', emptyConfig, 'status']), 0);
    expect(
      await CliRunner().run(['-c', emptyConfig, 'generate', '-n', 'nothing']),
      1,
    );
    expect(
      await CliRunner().run(
          ['-c', emptyConfig, 'generate', '--dart-only', '--dart', 'x.dart']),
      1,
      reason: 'an empty journal has nothing to embed',
    );

    Directory(p.join(fixture.path, 'empty_migrations')).createSync();
    expect(await CliRunner().run(['-c', emptyConfig, 'status']), 0);
  });

  test('--dart-only without a Dart output path is refused', () async {
    final noDartConfig = p.join(fixture.path, 'raindrop_no_dart.yaml');
    File(noDartConfig).writeAsStringSync('''
driver: raindrop_sqlite
schemas: lib
out: migrations
''');

    expect(
      await CliRunner().run(['-c', noDartConfig, 'generate', '--dart-only']),
      1,
    );
  });

  test('a schema outside lib cannot be imported and says so', () async {
    Directory(p.join(fixture.path, 'outside_lib')).createSync();
    File(p.join(fixture.path, 'outside_lib', 'schema.dart'))
        .writeAsStringSync(schemaSource());
    final outsideConfig = p.join(fixture.path, 'raindrop_outside.yaml');
    File(outsideConfig).writeAsStringSync('''
driver: raindrop_sqlite
schemas: outside_lib
out: outside_migrations
''');

    await expectLater(
      CliRunner().run(['-c', outsideConfig, 'generate', '-n', 'nope']),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('lib/'),
        ),
      ),
    );
  });

  test('two tables with one name fail snapshot building', () async {
    final dup = Directory(p.join(fixture.path, 'lib', 'dup'))..createSync();
    addTearDown(() => dup.deleteSync(recursive: true));
    File(p.join(fixture.path, 'lib', 'dup', 'schema.dart'))
        .writeAsStringSync(r'''
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class Twin {
  Twin({this.id});
  final int? id;
}

class TwinSchema extends Schema<Twin> {
  TwinSchema(super.$)
      : id = $.integer('id', (o) => o.id).primaryKey(autoIncrement: true);

  final ColumnType<int?> id;

  @override
  Twin fromRow(RowReader read) => Twin(id: read(id));
}

final a = sqliteTable('twins', TwinSchema.new);
final b = sqliteTable('twins', TwinSchema.new);
''');
    final dupConfig = p.join(fixture.path, 'raindrop_dup.yaml');
    File(dupConfig).writeAsStringSync('''
driver: raindrop_sqlite
schemas: lib/dup
out: dup_migrations
''');

    await expectLater(
      CliRunner().run(['-c', dupConfig, 'generate', '-n', 'nope']),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('snapshot failed'),
        ),
      ),
    );
  });

  test('a driver whose entrypoint cannot load is a loud error', () async {
    await expectLater(
      DdlRunner.generate(
        'broken_driver',
        [],
        projectPath: fixture.path,
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('could not be loaded'),
        ),
      ),
    );
  });

  test('a driver that renders no SQL has nothing to migrate', () async {
    final blankConfig = p.join(fixture.path, 'raindrop_blank.yaml');
    File(blankConfig).writeAsStringSync('''
driver: blank_driver
schemas: lib
out: blank_migrations
''');

    expect(
      await CliRunner().run(['-c', blankConfig, 'generate', '-n', 'nothing']),
      0,
    );
    expect(
      Directory(p.join(fixture.path, 'blank_migrations')).existsSync(),
      isFalse,
      reason: 'blank SQL must not produce a migration file',
    );
  });

  test('--current-snapshot must exist', () async {
    expect(
      await CliRunner().run([
        '-c', config, //
        'generate', '-n', 'nope', '--current-snapshot', 'missing.json',
      ]),
      1,
    );
  });

  test('--current-snapshot diffs against a stored snapshot', () async {
    expect(
      await CliRunner().run([
        '-c', config, //
        '--schemas', 'lib',
        'generate', '-n', 'from_snapshot',
        '--current-snapshot', 'migrations/meta/0000_snapshot.json',
      ]),
      0,
    );
  });

  test('flags work without a config file', () async {
    final previous = Directory.current;
    Directory.current = fixture;
    try {
      expect(
        await CliRunner().run([
          '-c',
          'nonexistent.yaml',
          '--driver',
          'raindrop_sqlite',
          '--schemas',
          'lib',
          '--out',
          'migrations',
          '--dart',
          'lib/flag_migrations.dart',
          'generate',
          '-n',
          'nothing',
        ]),
        0,
      );
    } finally {
      Directory.current = previous;
    }
  });

  test('no config and no flags is a loud error', () async {
    expect(
      () => CliRunner()
          .run(['-c', p.join(fixture.path, 'nonexistent.yaml'), 'status']),
      throwsA(isA<StateError>()),
    );
  });
}
