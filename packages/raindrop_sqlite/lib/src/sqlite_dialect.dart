import 'dart:typed_data';

import 'package:raindrop/dialect.dart';

/// This driver's dialect.
const dialect = SQLiteDialect();

/// {@template sqlite_dialect}
/// SQL dialect for the SQLite database.
/// {@endtemplate}
class SQLiteDialect extends SqlDialect {
  /// {@macro sqlite_dialect}
  const SQLiteDialect({this.supportsUpdateDeleteLimit = false});

  /// Whether the library being talked to parses a `LIMIT` hung directly off an
  /// `UPDATE` or a `DELETE`.
  ///
  /// True only for builds compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`,
  /// which is off in the stock amalgamation and in the binaries
  /// `package:sqlite3` ships. When false, a capped write is rendered as a key
  /// subquery instead, which every build parses — see `LimitedWriteClause`.
  ///
  /// Defaults to false because that form runs everywhere, and because it is
  /// the cheap direction to be wrong in: a needless subquery costs a plan,
  /// while a wrong yes is a syntax error at execution time. Saying yes is the
  /// caller's move — see `SQLiteDelegate.probeForLimitSupport` for asking the
  /// library instead of guessing.
  final bool supportsUpdateDeleteLimit;

  @override
  String get name => 'sqlite';

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';

  @override
  String escapeLiteral(Object? value) {
    return switch (value) {
      null => 'NULL',
      final bool boolean => boolean ? '1' : '0',
      final int number => '$number',
      final double number when number.isFinite => '$number',
      final String text => "'${text.replaceAll("'", "''")}'",
      final Uint8List bytes => "X'${_hex(bytes)}'",
      _ => throw ArgumentError.value(
          value,
          'value',
          'has no SQLite literal form',
        ),
    };
  }

  String _hex(Uint8List bytes) => [
        for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0'),
      ].join();
}
