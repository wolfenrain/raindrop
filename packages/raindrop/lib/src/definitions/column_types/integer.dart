import 'package:raindrop/raindrop.dart';

/// Comparison operators for integer columns.
extension IntOperators<V extends int?> on ColumnOf<V> {
  /// Row value of column is greater than [value].
  SQL greaterThan(ColumnOr<V> value) =>
      SQL([this, Op.greaterThan, operand(value)]);

  /// Row value of column is greater than or equal [value].
  SQL greaterThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.greaterThanOrEqual, operand(value)]);

  /// Row value of column is greater than [value].
  SQL operator >(ColumnOr<V> value) => greaterThan(value);

  /// Row value of column is greater than or equal [value].
  SQL operator >=(ColumnOr<V> value) => greaterThanOrEqual(value);

  /// Row value of column is less than [value].
  SQL lessThan(ColumnOr<V> value) => SQL([this, Op.lessThan, operand(value)]);

  /// Row value of column is less than or equal [value].
  SQL lessThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.lessThanOrEqual, operand(value)]);

  /// Row value of column is less than [value].
  SQL operator <(ColumnOr<V> value) => lessThan(value);

  /// Row value of column is less than or equal [value].
  SQL operator <=(ColumnOr<V> value) => lessThanOrEqual(value);
}
