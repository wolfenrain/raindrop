import 'package:raindrop/raindrop.dart';

/// {@template sql}
/// SQL-based logic, makes it easy to add custom SQL code.
/// {@endtemplate}
class SQL extends Filter {
  /// {@macro sql}
  SQL(List<Object?> chunks)
      : chunks = [
          ...chunks.map((e) {
            if (e case final ColumnType type) {
              try {
                return type.$;
              } catch (err) {
                return e;
              }
            }
          }),
        ];

  SQL.function(String name, List<Object?> chunks)
      : this([RawSQL('$name('), ...chunks, const RawSQL(')')]);

  /// The chunks of the SQL portion.
  final List<Object?> chunks;

  @override
  String toString() => chunks.join(' ');
}

/// {@template raw_sql}
/// Provides a raw SQL object.
/// {@endtemplate}
class RawSQL {
  /// {@macro raw_sql}
  const RawSQL(this.sql);

  /// The raw SQL itself.
  final String sql;

  @override
  String toString() => sql;
}

sealed class Op {
  /// The SQL equals operator.
  static const equals = RawSQL('=');

  /// The SQL greater than operator.
  static const greaterThan = RawSQL('>');

  /// The SQL greater than or equal operator.
  static const greaterThanOrEqual = RawSQL('>=');

  /// The SQL less than operator.
  static const lessThan = RawSQL('<');

  /// The SQL less than or equal operator.
  static const lessThanOrEqual = RawSQL('<=');
}
