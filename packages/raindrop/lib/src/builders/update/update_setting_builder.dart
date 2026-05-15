import 'package:raindrop/raindrop.dart';

/// {@template update_setting_builder}
/// Start of every update builder, the user has to set what it wants to update
/// first.
/// {@endtemplate}
class UpdateSettingBuilder<S extends Schema<R>, R, V> extends UpdateBuilder<S, R, V> {
  /// {@macro update_setting_builder}
  UpdateSettingBuilder(super.executor, {required super.config});
}

/// {@template update_where_builder}
/// Update builder that can be filtered down or turned into a query.
/// {@endtemplate}
class UpdateWhereBuilder<S extends Schema<R>, R, ST, V> extends UpdateBuilder<S, R, V>
    with ToQuery<S, V> {
  /// {@macro update_where_builder}
  UpdateWhereBuilder(super.executor, {required super.config});

  @override
  Update<S, R, V> toQuery() {
    return Update(
      set: config.get(#set)!,
      table: config.get(#table)!,
      where: config.get(#where),
    );
  }
}
