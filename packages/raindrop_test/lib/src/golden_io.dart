import 'dart:convert';
import 'dart:io';

import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

/// Returns [builder] as a terminal (awaitable) builder, failing the test
/// with a helpful message when a golden's build callback returned a
/// non-terminal one.
ToQuery<S, V> requireTerminalBuilder<S, V>(QueryBuilder<S, V> builder) {
  if (builder is! ToQuery<S, V>) {
    fail(
      'The build callback must return a terminal (awaitable) query '
      'builder, got ${builder.runtimeType}.',
    );
  }
  return builder;
}

/// Renders [sql] and its bind [values] into golden-file form.
///
/// The statement comes first, each bind value follows as a `-- $n = value`
/// comment line, so the fixture shows the complete query at a glance.
String renderGolden(String sql, List<Object?> values) {
  final buffer = StringBuffer()..writeln(sql);
  if (values.isNotEmpty) {
    buffer.writeln();
    for (var i = 0; i < values.length; i++) {
      // Some drivers bind rich objects (e.g. DateTime) directly, render
      // those via toString instead of failing to encode.
      final value = jsonEncode(values[i], toEncodable: (o) => o.toString());
      buffer.writeln('-- \$${i + 1} = $value');
    }
  }
  return buffer.toString();
}

/// The fixture path for a golden, derived from the test's position.
///
/// Group and test names are slugified and joined with underscores under
/// [directory]: a test `with limits` in group `select` and directory
/// `test/fixtures/sql` lands at `test/fixtures/sql/select_with_limits.sql`.
String goldenPath({
  required Iterable<String> groups,
  required String name,
  required String directory,
}) {
  final slugs = [
    ...groups.map(_slugify).where((s) => s.isNotEmpty),
    _slugify(name),
  ];
  return '$directory/${slugs.join('_')}.sql';
}

String _slugify(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

/// Compares [actual] against the golden [file].
///
/// A missing golden is written and the test fails, so a fresh fixture is
/// always inspected before it starts passing. With [update] set the file is
/// (re)written unconditionally, otherwise a mismatch fails the test.
void compareGolden(File file, String actual, {required bool update}) {
  if (!file.existsSync()) {
    file
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(actual);
    if (update) return;
    fail(
      '''
SQL golden did not exist, wrote ${file.path}. Inspect the file, then re-run.''',
    );
  }

  if (update) {
    return file.writeAsStringSync(actual);
  }

  expect(
    actual,
    file.readAsStringSync(),
    reason: '''
SQL differs from ${file.path}. If the change is intentional, re-run with UPDATE_GOLDENS=1.''',
  );
}
