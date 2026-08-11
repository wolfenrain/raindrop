import 'dart:typed_data';

import 'package:raindrop/dialect.dart';

/// This driver's dialect.
const dialect = PostgresDialect();

/// {@template postgres_dialect}
/// SQL dialect for the Postgres database.
/// {@endtemplate}
class PostgresDialect extends SqlDialect {
  /// {@macro postgres_dialect}
  const PostgresDialect();

  @override
  String get name => 'postgres';

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
      final Uint8List bytes => "'\\x${_hex(bytes)}'::bytea",
      _ => throw ArgumentError.value(
          value,
          'value',
          'has no Postgres literal form',
        ),
    };
  }

  String _hex(Uint8List bytes) => [
        for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0'),
      ].join();

  @override
  int matchQuoteDelimiter(String sql, int index) {
    final match = _dollarQuote.matchAsPrefix(sql, index);
    return match == null ? 0 : match.end - index;
  }

  /// Postgres dollar-quoting: `$$...$$` or `$tag$...$tag$`, used for function
  /// bodies, which routinely contain semicolons.
  static final _dollarQuote = RegExp(r'\$([A-Za-z_][A-Za-z0-9_]*)?\$');
}
