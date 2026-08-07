import 'package:raindrop/raindrop.dart';

/// SQL `ABS(value)`, the absolute value of [value], keeping its type.
Abs<V> abs<V extends num?>(ColumnOr<V> value) => Abs<V>(value);

/// {@template abs}
/// SQL `ABS(value)`.
/// {@endtemplate}
class Abs<V extends num?> extends Expression<V> {
  /// {@macro abs}
  Abs(this.value);

  /// The number.
  final ColumnOr<V> value;

  @override
  SQL build() => SQL.function('ABS', [value]);
}
