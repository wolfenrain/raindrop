import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

/// Declares a SQL-generation test case.
///
/// The [build] callback receives a [Raindrop] instance wired to an in-memory
/// SQLite delegate. It should return a [QueryBuilder]; the result is
/// translated via the dialect (never executed) and compared against a
/// fixture under `test/fixtures/sql/`.
///
/// Set `UPDATE_GOLDENS=1` to (re)write fixtures.
@isTest
void goldenTest<S, V>(
  String description,
  QueryBuilder<S, V> Function(Raindrop db) build,
) {
  test(description, () {
    final builder = build(_db);
    final compiled = (builder as ToQuery<S, V>).compile();
    final (sql, values) = const SQLiteDialect().translate(compiled);
    _expectGolden(_resolveFixturePath(), _format(sql, values));
  });
}

final _db = Raindrop(SQLiteDelegate(sqlite3.openInMemory()));

void _expectGolden(String path, String actual) {
  final file = File(path);
  final shouldUpdate = Platform.environment['UPDATE_GOLDENS'] == '1';

  if (!file.existsSync()) {
    file
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(actual);
    if (shouldUpdate) return;
    fail(
      'SQL golden did not exist; wrote ${file.path}. '
      'Inspect the file, then re-run.',
    );
  }

  if (shouldUpdate) {
    return file.writeAsStringSync(actual);
  }

  expect(
    actual,
    file.readAsStringSync(),
    reason: 'SQL differs from ${file.path}. '
        'If the change is intentional, re-run with UPDATE_GOLDENS=1.',
  );
}

String _resolveFixturePath() {
  final live = Invoker.current!.liveTest;
  // groups[0] is the implicit root group with an empty name; skip it.
  final groupSlugs = live.groups
      .skip(1)
      .map((g) => _slugify(g.name))
      .where((s) => s.isNotEmpty);

  final testSlug = _slugify(live.individualName);
  final segments = [...groupSlugs, testSlug];
  return 'test/fixtures/sql/${segments.join('_')}.sql';
}

String _slugify(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

String _format(String sql, List<Object?> values) {
  final buffer = StringBuffer()..writeln(sql);
  if (values.isNotEmpty) {
    buffer.writeln();
    for (var i = 0; i < values.length; i++) {
      buffer.writeln('-- \$${i + 1} = ${jsonEncode(values[i])}');
    }
  }
  return buffer.toString();
}
