import 'package:raindrop/raindrop.dart';

extension BoolOperators on ColumnOf<bool> {
  /// Row value of column is true.
  SQL isTrue() => SQL([$, Op.equals, 1]);

  /// Row value of column is false.
  SQL isFalse() => SQL([$, Op.equals, 0]);
}
