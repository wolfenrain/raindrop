import 'package:raindrop/raindrop.dart';

/// SQL `COALESCE(value, fallback)`, [value] when non-null, else [fallback].
Coalesce<V> coalesce<V>(ColumnOr<V> value, V fallback) =>
    Coalesce<V>(value, fallback);

/// {@template coalesce}
/// SQL `COALESCE(value, fallback)`.
/// {@endtemplate}
class Coalesce<V> extends Expression<V> {
  /// {@macro coalesce}
  Coalesce(this.value, this.fallback);

  /// The column or expression whose value is returned when non-null.
  final ColumnOr<V> value;

  /// The fallback value used when [value] is null.
  final V fallback;

  @override
  ColumnTransformer<V, Object?>? get transformer => transformerOf(value);

  /// [value] is already SQL but [fallback] is a literal and has to be encoded.
  @override
  SQL build() => SQL.function('COALESCE', [value, encode(fallback)]);
}
