import 'package:raindrop/raindrop.dart';

/// Predicates for boolean columns.
extension BoolOperators<V extends bool?> on ColumnOf<V> {
  /// Row value of column is true.
  SQL isTrue() => equals(true as V);

  /// Row value of column is false.
  SQL isFalse() => equals(false as V);
}
