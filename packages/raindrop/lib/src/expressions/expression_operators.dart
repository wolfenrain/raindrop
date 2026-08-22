import 'package:meta/meta.dart';
import 'package:raindrop/raindrop.dart';

/// Comparisons with an expression on the LEFT.
///
/// Deliberately mirrors [ColumnOperators] rather than sharing it. The two
/// cannot be one extension because a column is reached through a nullable
/// `ColumnOf<V>` and an expression through a non-nullable type, and an
/// extension on both would be ambiguous wherever both apply. The logic that
/// actually matters is how an operand is prepared.
extension ExpressionOperators<V> on Expression<V> {
  /// Value of this expression equals [value].
  SQL equals(ColumnOr<V> value) => SQL([this, Op.equals, operand(value)]);

  /// Value of this expression does not equal [value].
  SQL notEquals(ColumnOr<V> value) => SQL([this, Op.notEquals, operand(value)]);

  /// Value of this expression is null.
  SQL isNull() => SQL([this, const RawSQL('IS NULL')]);

  /// Value of this expression is not null.
  SQL isNotNull() => SQL([this, const RawSQL('IS NOT NULL')]);

  /// Value of this expression is in [values].
  ///
  /// An empty list can never match, so it emits an always-false predicate
  /// rather than the invalid `IN ()`.
  SQL inList(List<ColumnOr<V>> values) => switch (values) {
        final list when list.isEmpty => SQL([const RawSQL('1 = 0')]),
        final values => SQL([
            this,
            const RawSQL('IN'),
            [...values.map(operand)],
          ]),
      };

  /// Value of this expression is among the rows [query] returns.
  SQL inQuery(ToQuery<dynamic, V> query) =>
      SQL([this, const RawSQL('IN'), subquery(query)]);

  /// {@macro operand_for}
  @protected
  Object? operand(ColumnOr<V> value) => operandFor(this, value);
}

/// Ordering comparisons for an expression over a number.
///
/// Split from [ExpressionOperators] for the same reason the column ones are:
/// `>` on a string means something different from `>` on an int, and neither
/// should be offered on a type where it makes no sense.
extension NumericExpressionOperators<V extends num?> on Expression<V> {
  /// Value of this expression is greater than [value].
  SQL greaterThan(ColumnOr<V> value) =>
      SQL([this, Op.greaterThan, operand(value)]);

  /// Value of this expression is greater than or equal to [value].
  SQL greaterThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.greaterThanOrEqual, operand(value)]);

  /// Value of this expression is less than [value].
  SQL lessThan(ColumnOr<V> value) => SQL([this, Op.lessThan, operand(value)]);

  /// Value of this expression is less than or equal to [value].
  SQL lessThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.lessThanOrEqual, operand(value)]);

  /// Value of this expression is within the inclusive [low] to [and] range.
  SQL between(ColumnOr<V> low, {required ColumnOr<V> and}) => SQL([
        this,
        const RawSQL('BETWEEN'),
        operand(low),
        const RawSQL('AND'),
        operand(and),
      ]);
}

/// Text comparisons for an expression over a string.
extension StringExpressionOperators<V extends String?> on Expression<V> {
  /// Value of this expression matches the [value] pattern.
  SQL like(ColumnOr<V> value) =>
      SQL([this, const RawSQL('LIKE'), operand(value)]);

  /// Lexicographic ordering.
  SQL greaterThan(ColumnOr<V> value) =>
      SQL([this, Op.greaterThan, operand(value)]);

  /// Lexicographic ordering.
  SQL greaterThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.greaterThanOrEqual, operand(value)]);

  /// Lexicographic ordering.
  SQL lessThan(ColumnOr<V> value) => SQL([this, Op.lessThan, operand(value)]);

  /// Lexicographic ordering.
  SQL lessThanOrEqual(ColumnOr<V> value) =>
      SQL([this, Op.lessThanOrEqual, operand(value)]);

  /// Value of this expression is within the inclusive [low] to [and] range,
  /// lexicographically.
  SQL between(ColumnOr<V> low, {required ColumnOr<V> and}) => SQL([
        this,
        const RawSQL('BETWEEN'),
        operand(low),
        const RawSQL('AND'),
        operand(and),
      ]);
}
