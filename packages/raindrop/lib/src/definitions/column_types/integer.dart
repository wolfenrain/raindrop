import 'package:raindrop/raindrop.dart';

extension IntOperators on ColumnOf<int> {
  /// Row value of column equals [value].
  SQL equals(ColumnOr<int> value) => SQL([this, Op.equals, value]);

  /// Row value of column is greater than [value].
  SQL greaterThan(ColumnOr<int> value) => SQL([this, Op.greaterThan, value]);

  /// Row value of column is greater than or equal [value].
  SQL greaterThanOrEqual(ColumnOr<int> value) =>
      SQL([this, Op.greaterThanOrEqual, value]);

  /// Row value of column is greater than [value].
  SQL operator >(ColumnOr<int> value) => greaterThan(value);

  /// Row value of column is greater than or equal [value].
  SQL operator >=(ColumnOr<int> value) => greaterThanOrEqual(value);

  /// Row value of column is less than [value].
  SQL lessThan(ColumnOr<int> value) => SQL([this, Op.lessThan, value]);

  /// Row value of column is less than or equal [value].
  SQL lessThanOrEqual(ColumnOr<int> value) =>
      SQL([this, Op.lessThanOrEqual, value]);

  /// Row value of column is less than [value].
  SQL operator <(ColumnOr<int> value) => lessThan(value);

  /// Row value of column is less than or equal [value].
  SQL operator <=(ColumnOr<int> value) => lessThanOrEqual(value);
}
