import 'package:raindrop/raindrop.dart';

/// `COALESCE(value, fallback)`: [value], or [fallback] where [value] is
/// `NULL`.
///
/// The result is not nullable: a nullable column with a fallback reads as
/// its non-nullable type. The fallback is a literal, a column, or an
/// expression of that type.
Coalesce<V> coalesce<V extends Object>(
  ColumnOr<V?> value,
  ColumnOr<V> fallback,
) =>
    Coalesce<V>(value, fallback);

/// {@template coalesce}
/// The `COALESCE` function with one fallback.
/// {@endtemplate}
class Coalesce<V extends Object> extends Expression<V> {
  /// {@macro coalesce}
  Coalesce(this.value, this.fallback);

  /// The value that can be `NULL`.
  final ColumnOr<V?> value;

  /// What to use where [value] is `NULL`.
  final ColumnOr<V> fallback;

  @override
  ColumnTransformer<V, Object?>? get transformer =>
      transformerOf(value) as ColumnTransformer<V, Object?>?;

  @override
  SQL build() => SQL.function('COALESCE', [value, operandFor(this, fallback)]);
}
