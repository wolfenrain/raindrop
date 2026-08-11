import 'dart:io';

import 'package:meta/meta.dart';
import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/src/golden_io.dart';
import 'package:raindrop_test/src/test_delegate.dart';
import 'package:test/test.dart' as dart_test;
import 'package:test_api/backend.dart';

/// {@template golden_tester}
/// Declares SQL-generation golden tests for one dialect.
///
/// Each [test] builds a query against a [Raindrop] wired to a non-executing
/// [TestDelegate], translates it through [dialect] (never executing it), and
/// compares the result against a fixture under [directory]. The fixture path
/// is derived from the surrounding group and test names.
///
/// A missing fixture is written on first run and the test fails so the file
/// gets inspected before it starts passing. Run with `UPDATE_GOLDENS=1` to
/// (re)write fixtures after an intentional change.
///
/// ```dart
/// void main() {
///   final golden = GoldenTester(dialect: SQLiteDialect());
///
///   group('select', () {
///     golden.test('with limit', (db) {
///       return db.select(users.name).from(users).limit(1);
///     });
///     // Compared against test/fixtures/sql/select_with_limit.sql
///   });
/// }
/// ```
/// {@endtemplate}
class GoldenTester {
  /// {@macro golden_tester}
  GoldenTester({
    required this.dialect,
    this.directory = 'test/fixtures/sql',
  }) : _db = Raindrop(TestDelegate(dialect: dialect));

  /// The dialect queries are translated through.
  final SqlDialect dialect;

  /// Where fixtures live, relative to the package root.
  final String directory;

  final Raindrop _db;

  /// Declares a golden test named [description].
  ///
  /// The [build] callback receives a [Raindrop] backed by a non-executing
  /// [TestDelegate] carrying [dialect], and must return a terminal
  /// (awaitable) query builder.
  @isTest
  void test<S, V>(
    String description,
    QueryBuilder<S, V> Function(Raindrop db) build,
  ) {
    dart_test.test(description, () {
      final builder = requireTerminalBuilder(build(_db));

      // This package is a testing surface, which is exactly the audience the
      // annotation reserves compile() for.
      // ignore: invalid_use_of_visible_for_testing_member
      final compiled = builder.compile();
      final (sql, values) = dialect.translate(compiled);

      compareGolden(
        File(_resolveFixturePath()),
        renderGolden(sql, values),
        update: Platform.environment['UPDATE_GOLDENS'] == '1',
      );
    });
  }

  String _resolveFixturePath() {
    final live = Invoker.current!.liveTest;
    return goldenPath(
      // groups[0] is the implicit root group with an empty name, skip it.
      groups: live.groups.skip(1).map((g) => g.name),
      name: live.individualName,
      directory: directory,
    );
  }
}
