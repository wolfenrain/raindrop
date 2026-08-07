import 'package:raindrop/raindrop.dart';

/// SQL `SUM(value)`, the total of [value] across the group.
Sum<V> sum<V extends num?>(ColumnOr<V> value) => Sum<V>(value);

/// {@template sum}
/// SQL `SUM(value)`.
/// {@endtemplate}
class Sum<V extends num?> extends Expression<V> {
  /// {@macro sum}
  Sum(this.value);

  /// The column or expression being totalled.
  final ColumnOr<V> value;

  @override
  SQL build() => SQL.function('SUM', [value]);
}
