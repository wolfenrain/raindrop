import 'dart:io';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/conformance.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:raindrop_test/src/golden_io.dart';
import 'package:test/test.dart';

void main() {
  group('renderGolden', () {
    test('renders the statement alone when there are no values', () {
      expect(renderGolden('SELECT 1', []), 'SELECT 1\n');
    });

    test('appends one comment line per bind value', () {
      expect(
        renderGolden('SELECT ?', ['a', 2]),
        'SELECT ?\n\n-- \$1 = "a"\n-- \$2 = 2\n',
      );
    });
  });

  group('goldenPath', () {
    test('joins slugified group and test names under the directory', () {
      expect(
        goldenPath(
          groups: ['select', 'with joins'],
          name: 'ON clause!',
          directory: 'test/fixtures/sql',
        ),
        'test/fixtures/sql/select_with_joins_on_clause.sql',
      );
    });

    test('drops groups that slugify to nothing', () {
      expect(
        goldenPath(groups: ['---'], name: 'a b', directory: 'd'),
        'd/a_b.sql',
      );
    });
  });

  group('requireTerminalBuilder', () {
    test('passes a terminal builder through unchanged', () {
      final db = Raindrop(TestDelegate());
      final builder = db.select(users.name).from(users);

      expect(
        requireTerminalBuilder<Schema<User>, String>(builder),
        same(builder),
      );
    });

    test('fails the test for a non-terminal builder', () {
      final db = Raindrop(TestDelegate());

      expect(
        () => requireTerminalBuilder<Schema<User>, void>(db.update(users)),
        throwsA(isA<TestFailure>()),
      );
    });
  });

  group('compareGolden', () {
    late Directory scratch;

    setUp(() {
      scratch = Directory.systemTemp.createTempSync('raindrop_test_golden');
    });

    tearDown(() => scratch.deleteSync(recursive: true));

    File fixture(String name) => File('${scratch.path}/$name.sql');

    test('writes a missing golden and fails so it gets inspected', () {
      final file = fixture('missing');

      expect(
        () => compareGolden(file, 'SELECT 1\n', update: false),
        throwsA(isA<TestFailure>()),
      );
      expect(file.readAsStringSync(), 'SELECT 1\n');
    });

    test('writes a missing golden without failing in update mode', () {
      final file = fixture('missing_update');

      compareGolden(file, 'SELECT 1\n', update: true);

      expect(file.readAsStringSync(), 'SELECT 1\n');
    });

    test('passes when the golden matches', () {
      final file = fixture('match')..writeAsStringSync('SELECT 1\n');

      compareGolden(file, 'SELECT 1\n', update: false);
    });

    test('fails when the golden differs', () {
      final file = fixture('differs')..writeAsStringSync('SELECT 1\n');

      expect(
        () => compareGolden(file, 'SELECT 2\n', update: false),
        throwsA(isA<TestFailure>()),
      );
    });

    test('rewrites a differing golden in update mode', () {
      final file = fixture('rewrite')..writeAsStringSync('SELECT 1\n');

      compareGolden(file, 'SELECT 2\n', update: true);

      expect(file.readAsStringSync(), 'SELECT 2\n');
    });
  });
}
