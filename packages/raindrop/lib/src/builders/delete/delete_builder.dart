import 'package:raindrop/dialect.dart';

/// {@template delete_builder}
/// The base class of any delete builder.
/// {@endtemplate}
abstract class DeleteBuilder<S extends Schema<R>, R, V>
    extends QueryBuilder<S, V> {
  /// {@macro delete_builder}
  DeleteBuilder(super.executor, {required super.config});
}

/// {@template delete_all_builder}
/// Delete builder that does not have any kind of filtering.
/// {@endtemplate}
class DeleteAllBuilder<S extends Schema<R>, R, V> extends DeleteBuilder<S, R, V>
    with ToQuery<S, V> {
  /// {@macro delete_all_builder}
  DeleteAllBuilder(super.executor, {required super.config});

  /// Add a where clause to the builder.
  DeleteWhereBuilder<S, R, V> where(Filter where) {
    return DeleteWhereBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }

  @override
  Query<V> compile({bool qualified = false}) => Query<V>(
        shape: config.from!,
        clauses: {
          DeleteSlot.from: DeleteFromClause(config.from!),
          if (config.where case final where?)
            DeleteSlot.where: WhereClause(where, singleTable: true),
          ...config.buildExtras(),
        },
      );
}

/// {@template delete_where_builder}
/// Delete builder that does have filtering.
/// {@endtemplate}
class DeleteWhereBuilder<S extends Schema<R>, R, V>
    extends DeleteBuilder<S, R, V> with ToQuery<S, V> {
  /// {@macro delete_where_builder}
  DeleteWhereBuilder(super.executor, {required super.config});

  @override
  Query<V> compile({bool qualified = false}) => Query<V>(
        shape: config.from!,
        clauses: {
          DeleteSlot.from: DeleteFromClause(config.from!),
          if (config.where case final where?)
            DeleteSlot.where: WhereClause(where, singleTable: true),
          ...config.buildExtras(),
        },
      );
}
