import 'package:raindrop/dialect.dart';

/// {@template select_from_builder}
/// Select builder that knows from where it is selecting ([S]).
/// {@endtemplate}
class SelectFromBuilder<S extends Schema<R>, R, V> extends QueryBuilder<S, V>
    with ToQuery<S, V> {
  /// {@macro select_from_builder}
  SelectFromBuilder(super.executor, {required super.config});

  /// Set the [where] clause of the builder.
  SelectFromBuilder<S, R, V> where(Filter where) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }

  /// Set the [limit] clause of the builder.
  SelectFromBuilder<S, R, V> limit(int limit) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#limit: limit}),
    );
  }

  /// Set the [offset] clause of the builder.
  SelectFromBuilder<S, R, V> offset(int offset) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#offset: offset}),
    );
  }

  /// Set the [groupBy] clause of the builder.
  SelectFromBuilder<S, R, V> groupBy(Selectable<dynamic> groupBy) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#groupBy: groupBy}),
    );
  }

  /// Set the `HAVING` clause, which filters groups rather than rows:
  ///
  /// ```dart
  /// .groupBy(pets.ownerId).having(count(pets.id).greaterThan(2))
  /// ```
  SelectFromBuilder<S, R, V> having(Filter having) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#having: having}),
    );
  }

  /// Set the `ORDER BY` terms, mapping each column (or [Expression]) to its
  /// sort [Order]:
  ///
  /// ```dart
  /// .orderBy({users.lastName: Order.asc, users.firstName: Order.asc})
  /// // ORDER BY "last_name" ASC, "first_name" ASC
  /// ```
  SelectFromBuilder<S, R, V> orderBy(Map<Selectable<dynamic>, Order> terms) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #orderBy: [
          for (final entry in terms.entries)
            OrderBy(entry.key, descending: entry.value == Order.desc),
        ],
      }),
    );
  }

  @override
  Query<V> compile({bool qualified = false}) {
    final joins = config.joins;
    final singleTable = joins.isEmpty && !qualified;
    final orderBy = config.orderBy;
    final selecting = config.selecting!;
    return Query<V>(
      shape: selecting,
      clauses: {
        SelectSlot.verb: config.distinct
            ? const Keyword('SELECT DISTINCT')
            : const Keyword('SELECT'),
        SelectSlot.columns: SelectionClause(
          selecting,
          singleTable: singleTable,
        ),
        SelectSlot.from: FromClause(config.from!),
        if (joins.isNotEmpty) SelectSlot.joins: JoinsClause(joins),
        if (config.where case final where?)
          SelectSlot.where: WhereClause(where, singleTable: singleTable),
        if (config.groupBy case final groupBy?)
          SelectSlot.groupBy: GroupByClause(groupBy, singleTable: singleTable),
        if (config.having case final having?)
          SelectSlot.having: HavingClause(having, singleTable: singleTable),
        if (orderBy.isNotEmpty)
          SelectSlot.orderBy: OrderByClause(orderBy, singleTable: singleTable),
        if (config.limit case final limit?)
          SelectSlot.limit: LimitClause(limit),
        if (config.offset case final offset?)
          SelectSlot.offset: OffsetClause(offset),
        ...?config.extraClauses,
      },
    );
  }
}

/// {@template whole_row_from_builder}
/// A [SelectFromBuilder] produced by a whole-row `select()`, as opposed to an
/// explicit column projection.
///
/// Exists for the same reason as [ProjectionFromBuilder], from the other side:
/// `SelectFromBuilder<S, R, R>` cannot be told apart from a projection by an
/// extension, because `R` is free to widen to `Object` and then matches every
/// builder there is. A distinct class makes "whole row" a fact rather than a
/// coincidence of type inference.
/// {@endtemplate}
class WholeRowFromBuilder<S extends Schema<R>, R>
    extends SelectFromBuilder<S, R, R> {
  /// {@macro whole_row_from_builder}
  WholeRowFromBuilder(super.executor, {required super.config});

  @override
  WholeRowFromBuilder<S, R> where(Filter where) => WholeRowFromBuilder(
        executor,
        config: config.copyWith({#where: where}),
      );

  @override
  WholeRowFromBuilder<S, R> limit(int limit) => WholeRowFromBuilder(
        executor,
        config: config.copyWith({#limit: limit}),
      );

  @override
  WholeRowFromBuilder<S, R> offset(int offset) => WholeRowFromBuilder(
        executor,
        config: config.copyWith({#offset: offset}),
      );

  @override
  WholeRowFromBuilder<S, R> groupBy(Selectable<dynamic> groupBy) =>
      WholeRowFromBuilder(
        executor,
        config: config.copyWith({#groupBy: groupBy}),
      );

  @override
  WholeRowFromBuilder<S, R> having(Filter having) => WholeRowFromBuilder(
        executor,
        config: config.copyWith({#having: having}),
      );

  @override
  WholeRowFromBuilder<S, R> orderBy(Map<Selectable<dynamic>, Order> terms) =>
      WholeRowFromBuilder(
        executor,
        config: config.copyWith({
          #orderBy: [
            for (final entry in terms.entries)
              OrderBy(entry.key, descending: entry.value == Order.desc),
          ],
        }),
      );
}

/// {@template projection_from_builder}
/// A [SelectFromBuilder] produced by an explicit column projection
/// (`select(colA, colB, ...)`), as opposed to a whole-row `select()`.
///
/// The distinction is purely type-level: it lets `.join` keep the explicit
/// projection [V] (adding only the JOIN clause) instead of appending the
/// joined table to the result, which is what whole-row joins do. See
/// `ProjectionJoins`.
/// {@endtemplate}
class ProjectionFromBuilder<S extends Schema<R>, R, V>
    extends SelectFromBuilder<S, R, V> {
  /// {@macro projection_from_builder}
  ProjectionFromBuilder(super.executor, {required super.config});

  @override
  ProjectionFromBuilder<S, R, V> where(Filter where) => ProjectionFromBuilder(
        executor,
        config: config.copyWith({#where: where}),
      );

  @override
  ProjectionFromBuilder<S, R, V> limit(int limit) => ProjectionFromBuilder(
        executor,
        config: config.copyWith({#limit: limit}),
      );

  @override
  ProjectionFromBuilder<S, R, V> offset(int offset) => ProjectionFromBuilder(
        executor,
        config: config.copyWith({#offset: offset}),
      );

  @override
  ProjectionFromBuilder<S, R, V> groupBy(Selectable<dynamic> groupBy) =>
      ProjectionFromBuilder(
        executor,
        config: config.copyWith({#groupBy: groupBy}),
      );

  @override
  ProjectionFromBuilder<S, R, V> having(Filter having) => ProjectionFromBuilder(
        executor,
        config: config.copyWith({#having: having}),
      );

  @override
  ProjectionFromBuilder<S, R, V> orderBy(
          Map<Selectable<dynamic>, Order> terms) =>
      ProjectionFromBuilder(
        executor,
        config: config.copyWith({
          #orderBy: [
            for (final entry in terms.entries)
              OrderBy(entry.key, descending: entry.value == Order.desc),
          ],
        }),
      );
}

/// {@template single_projection_from_builder}
/// A [ProjectionFromBuilder] for a projection of exactly one column.
///
/// A one-column projection's element type is that column's type rather than a
/// 1-tuple, so it cannot be told apart from any other arity by element type
/// alone. `V0` unifies with `(int, int)` just as happily. This class makes the
/// distinction on the receiver instead, which is what lets `derived()` exist at
/// every arity.
/// {@endtemplate}
class SingleProjectionFromBuilder<S extends Schema<R>, R, V>
    extends ProjectionFromBuilder<S, R, V> {
  /// {@macro single_projection_from_builder}
  SingleProjectionFromBuilder(super.executor, {required super.config});

  @override
  SingleProjectionFromBuilder<S, R, V> where(Filter where) =>
      SingleProjectionFromBuilder(
        executor,
        config: config.copyWith({#where: where}),
      );

  @override
  SingleProjectionFromBuilder<S, R, V> limit(int limit) =>
      SingleProjectionFromBuilder(
        executor,
        config: config.copyWith({#limit: limit}),
      );

  @override
  SingleProjectionFromBuilder<S, R, V> offset(int offset) =>
      SingleProjectionFromBuilder(
        executor,
        config: config.copyWith({#offset: offset}),
      );

  @override
  SingleProjectionFromBuilder<S, R, V> groupBy(Selectable<dynamic> groupBy) =>
      SingleProjectionFromBuilder(
        executor,
        config: config.copyWith({#groupBy: groupBy}),
      );

  @override
  SingleProjectionFromBuilder<S, R, V> having(Filter having) =>
      SingleProjectionFromBuilder(
        executor,
        config: config.copyWith({#having: having}),
      );

  @override
  SingleProjectionFromBuilder<S, R, V> orderBy(
    Map<Selectable<dynamic>, Order> terms,
  ) =>
      SingleProjectionFromBuilder(
        executor,
        config: config.copyWith({
          #orderBy: [
            for (final entry in terms.entries)
              OrderBy(entry.key, descending: entry.value == Order.desc),
          ],
        }),
      );
}
