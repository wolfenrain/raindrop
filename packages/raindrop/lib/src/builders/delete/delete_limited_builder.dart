import 'package:raindrop/dialect.dart';

/// {@template delete_limited_builder}
/// A delete whose row cap is set: still awaitable and decoratable, no
/// longer filterable.
/// {@endtemplate}
class DeleteLimitedBuilder<S extends Schema<R>, R, V>
    extends DeleteBuilder<S, R, V> with ToQuery<S, V> {
  /// {@macro delete_limited_builder}
  DeleteLimitedBuilder(super.executor, {required super.config});

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
