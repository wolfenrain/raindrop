import 'package:raindrop/raindrop.dart';

extension BoolOperators<V extends bool?> on ColumnOf<V> {
  /// Row value of column is true.
  SQL isTrue() => SQL([this, Op.equals, 1]);

  /// Row value of column is false.
  SQL isFalse() => SQL([this, Op.equals, 0]);
}
