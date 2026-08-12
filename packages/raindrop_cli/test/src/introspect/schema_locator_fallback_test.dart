import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/src/introspect/schema_locator.dart';
import 'package:test/test.dart';

/// The analyzer-free path `SchemaLocator` takes when the CLI is running from
/// an AOT-compiled binary. CI always runs under the Dart VM, so nothing else
/// in this suite ever reaches it -- these tests are its only coverage.
void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('locator_fallback'));
  tearDown(() => dir.deleteSync(recursive: true));

  String write(String name, String content) {
    final file = File(p.join(dir.path, name))
      ..writeAsStringSync(content);
    return file.path;
  }

  test('finds table declarations without resolving types', () {
    final path = write('schemas.dart', '''
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

final users = sqliteTable('users', UserSchema.new);
final pets = sqliteTable('pets', PetSchema.new);
''');

    final found = SchemaLocator().locateWithoutAnalyzer([path]);

    expect(found.map((s) => s.variableName), ['users', 'pets']);
    expect(found.every((s) => s.filePath == path), isTrue);
  });

  test('ignores top-level variables that are not tables', () {
    // Every name this returns is emitted into the generated entrypoint, so a
    // non-table slipping through would produce source that does not compile.
    final path = write('mixed.dart', '''
const schemaVersion = 3;
final logger = Logger('db');
final users = sqliteTable('users', UserSchema.new);
''');

    final found = SchemaLocator().locateWithoutAnalyzer([path]);

    expect(found.map((s) => s.variableName), ['users']);
  });

  test('finds a table declared with an explicit type annotation', () {
    final path = write('typed.dart', '''
final Table<UserSchema, User> users = sqliteTable('users', UserSchema.new);
''');

    final found = SchemaLocator().locateWithoutAnalyzer([path]);

    expect(found.map((s) => s.variableName), ['users']);
  });

  test('matches other drivers, not just sqlite', () {
    final path = write('pg.dart', '''
final users = postgresTable('users', UserSchema.new);
''');

    final found = SchemaLocator().locateWithoutAnalyzer([path]);

    expect(found.map((s) => s.variableName), ['users']);
  });
}
