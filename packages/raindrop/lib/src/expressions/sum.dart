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

  @override
  V? decode(Object? input) => switch (input) {
        null => null,
        final V value => value,
        final num number => _toV(number),
        final String text => _toV(num.parse(text)),
        _ => input as V?,
      };

  /// Converts [number] to whichever numeric type [V] accepts.
  V _toV(num number) {
    if (number is V) return number as V;
    if (0 is V) return number.toInt() as V;
    if (0.0 is V) return number.toDouble() as V;
    return number as V;
  }
}
