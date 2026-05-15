import 'package:raindrop/raindrop.dart';

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

  @override
  Select<S, R, V> toQuery() {
    return Select(
      selecting: config.get(#selecting)!,
      from: config.get(#from)!,
      joins: config.get(#joins, orElse: <Join>[])!.cast(),
      where: config.get(#where),
      limit: config.get(#limit),
      offset: config.get(#offset),
      groupBy: config.get(#groupBy),
    );
  }
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
