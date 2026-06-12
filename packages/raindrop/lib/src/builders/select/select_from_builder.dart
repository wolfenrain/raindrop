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
  Query<V> compile() {
    final joins = config.get(#joins, orElse: <Join>[])!.cast<Join>();
    final singleTable = joins.isEmpty;
    final orderBy =
        config.get(#orderBy, orElse: const <OrderBy>[])!.cast<OrderBy>();
    return Query<V>(
      shape: config.get(#selecting)! as Selectable<Object?>,
      clauses: {
        SelectSlot.verb: const Keyword('SELECT'),
        SelectSlot.columns: SelectionClause(
          config.get(#selecting)! as Selectable<dynamic>,
          singleTable: singleTable,
        ),
        SelectSlot.from: FromClause(config.get(#from)! as Table),
        if (joins.isNotEmpty) SelectSlot.joins: JoinsClause(joins),
        if (config.get<Filter>(#where) case final where?)
          SelectSlot.where: WhereClause(where, singleTable: singleTable),
        if (config.get<Selectable<dynamic>>(#groupBy) case final groupBy?)
          SelectSlot.groupBy: GroupByClause(groupBy, singleTable: singleTable),
        if (orderBy.isNotEmpty)
          SelectSlot.orderBy: OrderByClause(orderBy, singleTable: singleTable),
        if (config.get<int>(#limit) case final limit?)
          SelectSlot.limit: LimitClause(limit),
        if (config.get<int>(#offset) case final offset?)
          SelectSlot.offset: OffsetClause(offset),
        ...?config.get<Map<int, Clause>>(#extraClauses),
      },
    );
  }
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
}

// TODO: come up with a way for select from with join with a custom select.
// extension SelectWithInnerJoin1<S> on SelectFromBuilder<S, S> {
//   /// Set a join clause of the builder.
//   SelectFromBuilder<S, (S, O)> join<O extends Schema<O, dynamic>>(
//     O table, {
//     required Filter on,
//   }) {
//     final (s) = config.get(#selecting) as Table<S>;
//     final o = Table.get(table)! as Table<O>;

//     return SelectFromBuilder(
//       executor,
//       config: config.copyWith({
//         #selecting: SelectableResult<(S, O)>([s, o]),
//         #joins: <Join>[
//           ...(config.get(#joins) ?? []),
//           InnerJoin<O>(o, on: on),
//         ],
//       }),
//     );
//   }
// }

// extension SelectWithInnerJoin2<
//     S extends Schema<S>,
//     S1 extends Schema<S1>? //
//     > on SelectFromBuilder<S, (S, S1)> {
//   /// Set a join clause of the builder.
//   SelectFromBuilder<S, (S, S1, O)> join<O extends Schema<O, dynamic>>(
//     O table, {
//     required Filter on,
//   }) {
//     final result = config.get(#selecting) as SelectableResult;
//     final o = Table.get(table)! as Table<O>;

//     return SelectFromBuilder(
//       executor,
//       config: config.copyWith({
//         #selecting: SelectableResult<(S, S1, O)>([...result.selected, o]),
//         #joins: <Join>[
//           ...(config.get(#joins) ?? []),
//           InnerJoin<O>(o, on: on),
//         ],
//       }),
//     );
//   }
// }

// extension SelectWithLeftJoin1<S> on SelectFromBuilder<S, S> {
//   /// Set a left join clause of the builder.
//   SelectFromBuilder<S, (S, O?)> leftJoin<O extends Schema<O, dynamic>>(
//     O table, {
//     required Filter on,
//   }) {
//     final (s) = config.get(#selecting) as Table<S>;
//     final o = Table.get(table)! as Table<O>;

//     return SelectFromBuilder(
//       executor,
//       config: config.copyWith({
//         #selecting: SelectableResult<(S, O)>([s, o]),
//         #joins: <Join>[
//           ...config.get(#joins) ?? [],
//           LeftJoin<O>(Table.get(table)! as Table<O>, on: on),
//         ],
//       }),
//     );
//   }
// }

// extension SelectWithLeftJoin2<
//     S extends Schema<S>,
//     S1 extends Schema<S1>? //
//     > on SelectFromBuilder<S, (S, S1)> {
//   /// Set a left join clause of the builder.
//   SelectFromBuilder<S, (S, S1, O?)> leftJoin<O extends Schema<O, dynamic>>(
//     O table, {
//     required Filter on,
//   }) {
//     final result = config.get(#selecting) as SelectableResult;
//     final o = Table.get(table)! as Table<O>;

//     return SelectFromBuilder(
//       executor,
//       config: config.copyWith({
//         #selecting: SelectableResult<(S, S1, O)>([...result.selected, o]),
//         #joins: <Join>[
//           ...config.get(#joins) ?? [],
//           LeftJoin<O>(Table.get(table)! as Table<O>, on: on),
//         ],
//       }),
//     );
//   }
// }
