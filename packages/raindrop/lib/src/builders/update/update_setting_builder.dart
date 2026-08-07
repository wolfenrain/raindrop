import 'package:raindrop/dialect.dart';

/// {@template update_setting_builder}
/// Start of every update builder, the user has to set what it wants to update
/// first.
/// {@endtemplate}
class UpdateSettingBuilder<S extends Schema<R>, R, V>
    extends UpdateBuilder<S, R, V> {
  /// {@macro update_setting_builder}
  UpdateSettingBuilder(super.executor, {required super.config});
}

/// {@template update_where_builder}
/// Update builder that can be filtered down or turned into a query.
/// {@endtemplate}
class UpdateWhereBuilder<S extends Schema<R>, R, V>
    extends UpdateBuilder<S, R, V> with ToQuery<S, V> {
  /// {@macro update_where_builder}
  UpdateWhereBuilder(super.executor, {required super.config});

  /// Filter which rows the update applies to.
  UpdateWhereBuilder<S, R, V> where(Filter where) {
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }

  @override
  Query<V> compile({bool qualified = false}) => Query<V>(
        shape: config.get(#table)! as Table,
        clauses: {
          UpdateSlot.verb: const Keyword('UPDATE'),
          UpdateSlot.table: TableClause(config.get(#table)! as Table),
          UpdateSlot.set: SetClause(config.get(#set)! as Updateable<dynamic>),
          if (config.get<Filter>(#where) case final where?)
            UpdateSlot.where: WhereClause(where, singleTable: true),
          ...?config.get<Map<int, Clause>>(#extraClauses),
        },
      );
}
