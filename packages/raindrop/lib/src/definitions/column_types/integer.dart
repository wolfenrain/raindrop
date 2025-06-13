import 'package:raindrop/raindrop.dart';

extension IntOperators on ColumnOf<int> {
  /// Row value of column equals [value].
  SQL equals(int value) => SQL([$, Op.equals, value]);

  /// Row value of column is greater than [value].
  SQL greaterThan(int value) => SQL([$, Op.greaterThan, value]);

  /// Row value of column is greater than or equal [value].
  SQL greaterThanOrEqual(int value) => SQL([$, Op.greaterThanOrEqual, value]);

  /// Row value of column is greater than [value].
  SQL operator >(int value) => greaterThan(value);

  /// Row value of column is greater than or equal [value].
  SQL operator >=(int value) => greaterThanOrEqual(value);

  /// Row value of column is less than [value].
  SQL lessThan(int value) => SQL([$, Op.lessThan, value]);

  /// Row value of column is less than or equal [value].
  SQL lessThanOrEqual(int value) => SQL([$, Op.lessThanOrEqual, value]);

  /// Row value of column is less than [value].
  SQL operator <(int value) => lessThan(value);

  /// Row value of column is less than or equal [value].
  SQL operator <=(int value) => lessThanOrEqual(value);
}
