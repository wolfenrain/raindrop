import 'package:raindrop/raindrop.dart';

/// {@template update_setting_builder}
/// Start of every update builder, the user has to set what it wants to update
/// first.
/// {@endtemplate}
class UpdateSettingBuilder<S extends Schema<S>, R> extends UpdateBuilder<S, R> {
  /// {@macro update_setting_builder}
  UpdateSettingBuilder(super.executor, {required super.config});

  /// Set the rows to update.
  UpdateWhereBuilder<S, V, R> set<V>(Updateable<V> set) {
    return UpdateWhereBuilder(executor, config: config.copyWith({#set: set}));
  }
}

/// {@template update_where_builder}
/// Update builder that can be filtered down or turned into a query.
/// {@endtemplate}
class UpdateWhereBuilder<S extends Schema<S>, V, R> extends UpdateBuilder<S, R>
    with ToQuery<S, R> {
  /// {@macro update_where_builder}
  UpdateWhereBuilder(super.executor, {required super.config});

  /// Filter the update query.
  UpdateWhereBuilder<S, V, R> where(Filter where) {
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }

  @override
  Update<S, R> toQuery() {
    return Update(
      set: config.get(#set)!,
      table: config.get(#table)!,
      where: config.get(#where),
    );
  }
}
