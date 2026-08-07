import 'package:raindrop/raindrop.dart';

/// {@template expression}
/// A typed SQL expression that produces a value of type [V].
/// {@endtemplate}
abstract class Expression<V> with SqlOperand<V> implements Selectable<V> {
  /// {@macro expression}
  const Expression();

  /// Build the underlying [SQL] for this expression.
  SQL build();

  /// Give this expression an output name, as `Column.as` does for a column.
  AliasedExpression<V> as(String alias) => AliasedExpression<V>(this, alias);
}

/// {@template aliased_expression}
/// An [Expression] carrying an output name for a projection.
/// {@endtemplate}
class AliasedExpression<V> extends Expression<V> {
  /// {@macro aliased_expression}
  const AliasedExpression(this.expression, this.alias);

  /// The expression being named.
  final Expression<V> expression;

  /// The name it is given in the result.
  final String alias;

  /// Naming a value does not change it.
  @override
  ColumnTransformer<V, Object?>? get transformer => expression.transformer;

  @override
  SQL build() => expression.build();
}
