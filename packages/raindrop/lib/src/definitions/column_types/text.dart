import 'package:raindrop/raindrop.dart';

/// Pattern-matching and comparison operators for text columns.
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

  /// Row value of column is within the inclusive [low] to [and] range,
  /// lexicographically.
  SQL between(ColumnOr<V> low, {required ColumnOr<V> and}) => SQL([
        this,
        const RawSQL('BETWEEN'),
        operand(low),
        const RawSQL('AND'),
        operand(and),
      ]);
}
