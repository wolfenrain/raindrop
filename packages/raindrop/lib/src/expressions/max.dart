import 'package:raindrop/raindrop.dart';

/// SQL `MAX(value)`, the largest value of [value] across the group.
Max<V> max<V>(ColumnOr<V> value) => Max<V>(value);

/// {@template max}
/// SQL `MAX(value)`.
/// {@endtemplate}
class Max<V> extends Expression<V> {
  /// {@macro max}
  Max(this.value);

  /// The column or expression being aggregated.
  final ColumnOr<V> value;

  @override
  ColumnTransformer<V, Object?>? get transformer => transformerOf(value);

  @override
  SQL build() => SQL.function('MAX', [value]);
}
