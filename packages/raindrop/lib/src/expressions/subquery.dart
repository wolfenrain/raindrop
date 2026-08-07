import 'package:raindrop/dialect.dart';

/// Embeds [query] where a value is expected.
///
/// ```dart
/// final youngest = subquery(db.select(min(users.age)).from(users));
/// db.select().from(users).where(users.age.equals(youngest));
/// ```
Subquery<V> subquery<V>(ToQuery<dynamic, V> query) =>
    Subquery<V>(query.compileEmbedded(qualified: true));

/// {@template subquery}
/// A `SELECT` standing where a value is expected.
/// {@endtemplate}
class Subquery<V> extends Expression<V> {
  /// {@macro subquery}
  const Subquery(this.query);

  /// The compiled statement being embedded.
  final Query<V> query;

  @override
  ColumnTransformer<V, Object?>? get transformer => switch (query.shape) {
        final SqlOperand<V> operand => operand.transformer,
        _ => null,
      };

  @override
  SQL build() =>
      SQL([const RawSQL('('), QueryClause(query), const RawSQL(')')]);
}
