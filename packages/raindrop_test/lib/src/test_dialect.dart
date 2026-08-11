import 'package:raindrop/dialect.dart';

/// {@template test_dialect}
/// An ANSI-flavored [SqlDialect] for tests that do not target a driver.
///
/// Identifiers are double-quoted and bind parameters render as `$1`, `$2`,
/// and so on. Booleans render as `TRUE`/`FALSE`; values without a portable
/// literal form (such as byte arrays) throw, since no single rendering would
/// be right for every database.
/// {@endtemplate}
class TestDialect extends SqlDialect {
  /// {@macro test_dialect}
  const TestDialect();

  @override
  String get name => 'test';

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';

  @override
  String escapeLiteral(Object? value) {
    return switch (value) {
      null => 'NULL',
      final bool boolean => boolean ? 'TRUE' : 'FALSE',
      final int number => '$number',
      final double number when number.isFinite => '$number',
      final String text => "'${text.replaceAll("'", "''")}'",
      _ => throw ArgumentError.value(
          value,
          'value',
          'has no portable literal form',
        ),
    };
  }
}
