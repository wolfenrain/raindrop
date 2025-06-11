import 'package:raindrop/raindrop.dart';

/// {@template sql}
/// SQL-based filter, makes it easy to add custom SQL code.
/// {@endtemplate}
class SQL extends Filter {
  /// {@macro sql}
  SQL(Column column, String operation, Object? value)
      : this.multiple([column, RawSQL(operation), value]);

  /// {@macro sql}
  ///
  /// Provide a raw SQL statement
  SQL.raw(String raw) : this.multiple([raw]);

  /// {@macro sql}
  ///
  /// Provide multiple chunks.
  const SQL.multiple(this.chunks);

  /// The SQL chunks.
  final List<Object?> chunks;
}

/// {@template raw_sql}
/// Provides a raw SQL object.
/// {@endtemplate}
class RawSQL {
  /// {@macro raw_sql}
  const RawSQL(this.sql);

  /// The raw SQL itself.
  final String sql;
}
