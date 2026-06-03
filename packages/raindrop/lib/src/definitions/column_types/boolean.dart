import 'package:raindrop/raindrop.dart';

extension BoolOperators on ColumnOf<bool> {
  /// Row value of column is true.
  SQL isTrue() => SQL([this, Op.equals, 1]);

  /// Row value of column is false.
  SQL isFalse() => SQL([this, Op.equals, 0]);
}
