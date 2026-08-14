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

  /// Whether the library parses a `LIMIT` hung directly off an `UPDATE` or a
  /// `DELETE`.
  ///
  /// `SQLiteDelegate` fills this in by probing its database
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
