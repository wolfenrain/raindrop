import 'package:raindrop/raindrop.dart';

/// SQL `DISTINCT value`, for an aggregate's operand.
///
/// ```dart
/// db.select(count(distinct(users.favoriteGame))).from(users);
/// // SELECT COUNT(DISTINCT "favoriteGame") FROM "users"
///
/// db.select(sum(distinct(orders.total))).from(orders);
/// // SELECT SUM(DISTINCT "total") FROM "orders"
/// ```
Distinct<V> distinct<V>(Selectable<V> value) => Distinct<V>(value);

/// {@template distinct}
/// SQL `DISTINCT value`.
/// {@endtemplate}
class Distinct<V> extends Expression<V> {
  /// {@macro distinct}
  const Distinct(this.value);

  /// What is being de-duplicated.
  final Selectable<V> value;

  @override
  ColumnTransformer<V, Object?>? get transformer => switch (value) {
        final SqlOperand<V> operand => operand.transformer,
        _ => null,
      };

  @override
  SQL build() => SQL([const RawSQL('DISTINCT'), value]);
}
