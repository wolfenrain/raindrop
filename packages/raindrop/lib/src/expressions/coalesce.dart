import 'package:raindrop/raindrop.dart';

/// SQL `COALESCE(value, fallback)`, [value] when non-null, else [fallback].
Coalesce<V> coalesce<V>(ColumnOf<V> value, V fallback) =>
    Coalesce<V>(value, fallback);

/// {@template coalesce}
/// SQL `COALESCE(value, fallback)`.
/// {@endtemplate}
class Coalesce<V> extends Expression<V> {
  /// {@macro coalesce}
  Coalesce(this.value, this.fallback);

  /// The column whose value is returned when non-null.
  final ColumnOf<V> value;

  /// The fallback value used when [value] is null.
  final V fallback;

  @override
  SQL build() => SQL.function('COALESCE', [value, fallback]);
}
