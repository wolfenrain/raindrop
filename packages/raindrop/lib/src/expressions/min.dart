import 'package:raindrop/raindrop.dart';

/// SQL `MIN(value)`, the smallest value of [value] across the group.
Min<V> min<V>(ColumnOr<V> value) => Min<V>(value);

/// {@template min}
/// SQL `MIN(value)`.
/// {@endtemplate}
class Min<V> extends Expression<V> {
  /// {@macro min}
  Min(this.value);

  /// The column or expression being aggregated.
  final ColumnOr<V> value;

  @override
  ColumnTransformer<V, Object?>? get transformer => transformerOf(value);

  @override
  SQL build() => SQL.function('MIN', [value]);
}
