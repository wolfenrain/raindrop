import 'package:raindrop/raindrop.dart';

/// {@template delete_builder}
/// The base class of any delete builder.
/// {@endtemplate}
abstract class DeleteBuilder<S extends Schema<S>, V>
    extends QueryBuilder<S, V> {
  /// {@macro delete_builder}
  DeleteBuilder(super.executor, {required super.config});
}

/// {@template delete_all_builder}
/// Delete builder that does not have any kind of filtering.
/// {@endtemplate}
class DeleteAllBuilder<S extends Schema<S>, V> extends DeleteBuilder<S, V>
    with ToQuery<S, V> {
  /// {@macro delete_all_builder}
  DeleteAllBuilder(super.executor, {required super.config});

  /// Add a where clause to the builder.
  DeleteWhereBuilder<S, V> where(Filter where) {
    return DeleteWhereBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }

  @override
  Delete<S, V> toQuery() {
    return Delete(from: config.get(#from) as Table<S>);
  }
}

/// {@template delete_where_builder}
/// Delete builder that does have filtering.
/// {@endtemplate}
class DeleteWhereBuilder<S extends Schema<S>, V> extends DeleteBuilder<S, V>
    with ToQuery<S, V> {
  /// {@macro delete_where_builder}
  DeleteWhereBuilder(super.executor, {required super.config});

  @override
  Delete<S, V> toQuery() {
    return Delete(
      from: config.get(#from) as Table<S>,
      where: config.get(#where),
    );
  }
}
