import 'package:raindrop/raindrop.dart';

/// SQL `MAX(value)`, the largest value of [value] across the group.
Max<V> max<V>(ColumnOf<V> value) => Max<V>(value);

/// {@template max}
/// SQL `MAX(value)`.
/// {@endtemplate}
class Max<V> extends Expression<V> {
  /// {@macro max}
  Max(this.value);

  /// The column being aggregated.
  final ColumnOf<V> value;

  @override
  SQL build() => SQL.function('MAX', [value]);
}
