import 'package:raindrop/raindrop.dart';

/// {@template select_from_builder}
/// Select builder that knows from where it is selecting ([S]).
/// {@endtemplate}
class SelectFromBuilder<S extends Schema<S>, V> extends QueryBuilder<S, V>
    with ToQuery<S, V> {
  /// {@macro select_from_builder}
  SelectFromBuilder(super.executor, {required super.config});

  /// Set the [where] clause of the builder.
  SelectFromBuilder<S, V> where(Filter where) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }

  /// Set the [limit] clause of the builder.
  SelectFromBuilder<S, V> limit(int limit) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#limit: limit}),
    );
  }

  /// Set the [offset] clause of the builder.
  SelectFromBuilder<S, V> offset(int offset) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#offset: offset}),
    );
  }

  /// Set the [groupBy] clause of the builder.
  SelectFromBuilder<S, V> groupBy(Selectable<dynamic> groupBy) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#groupBy: groupBy}),
    );
  }

  /// Set a join clause of the builder.
  SelectFromBuilder<S, V> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...(config.get(#joins) ?? []),
          InnerJoin<O>(Table.getForSchema<O>()!, on: on),
        ],
      }),
    );
  }

  /// Set a left join clause of the builder.
  SelectFromBuilder<S, V> leftJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<O>(Table.getForSchema<O>()!, on: on),
        ],
      }),
    );
  }

  /// Set a right join clause of the builder.
  SelectFromBuilder<S, V> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(Table.getForSchema<O>()!, on: on),
        ],
      }),
    );
  }

  @override
  Select<S, V> toQuery() {
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
