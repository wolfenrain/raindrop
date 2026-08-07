import 'package:raindrop/raindrop.dart';

extension StringOperators<V extends String?> on ColumnOf<V> {
  /// String like [value].
  SQL like(ColumnOr<V> value) =>
      SQL([this, const RawSQL('LIKE'), operand(value)]);

  /// Lexicographic ordering.
  SQL greaterThan(ColumnOr<V> value) =>
      SQL([this, Op.greaterThan, operand(value)]);

  /// Lexicographic ordering.
  SQL greaterThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.greaterThanOrEqual, operand(value)]);

  /// Lexicographic ordering.
  SQL lessThan(ColumnOr<V> value) => SQL([this, Op.lessThan, operand(value)]);

  /// Lexicographic ordering.
  SQL lessThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.lessThanOrEqual, operand(value)]);
}
