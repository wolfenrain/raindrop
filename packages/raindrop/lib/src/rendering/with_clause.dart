import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/rendering/clause.dart';

/// Adds [withClause] to a select builder.
extension SelectFromWithClause<S extends Schema<R>, R, V>
    on SelectFromBuilder<S, R, V> {
  /// Returns a copy of this builder with [clause] placed at [weight].
  SelectFromBuilder<S, R, V> withClause(int weight, Clause clause) =>
      SelectFromBuilder(executor, config: config.addClause(weight, clause));
}

/// Adds [withClause] to a pre-`values` insert builder (to seed a verb
/// modifier like `OR IGNORE` before the rows are supplied).
extension InsertValuesWithClause<S extends Schema<R>, R, V>
    on InsertValuesBuilder<S, R, V> {
  /// Returns a copy of this builder with [clause] placed at [weight].
  InsertValuesBuilder<S, R, V> withClause(int weight, Clause clause) =>
      InsertValuesBuilder(executor, config: config.addClause(weight, clause));
}

/// Adds [withClause] to an insert builder.
extension InsertWithValuesWithClause<S extends Schema<R>, R, V>
    on InsertWithValuesBuilder<S, R, V> {
  /// Returns a copy of this builder with [clause] placed at [weight].
  InsertWithValuesBuilder<S, R, V> withClause(int weight, Clause clause) =>
      InsertWithValuesBuilder(
        executor,
        config: config.addClause(weight, clause),
      );
}

/// Adds [withClause] to an update builder.
extension UpdateWhereWithClause<S extends Schema<R>, R, V>
    on UpdateWhereBuilder<S, R, V> {
  /// Returns a copy of this builder with [clause] placed at [weight].
  UpdateWhereBuilder<S, R, V> withClause(int weight, Clause clause) =>
      UpdateWhereBuilder(executor, config: config.addClause(weight, clause));
}

/// Adds [withClause] to a delete builder.
extension DeleteWhereWithClause<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  /// Returns a copy of this builder with [clause] placed at [weight].
  DeleteWhereBuilder<S, R, V> withClause(int weight, Clause clause) =>
      DeleteWhereBuilder(executor, config: config.addClause(weight, clause));
}

/// Adds [yieldingRows] to an insert builder.
extension InsertYieldingRows<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  /// Returns a copy of this builder with the clause built by [clause] over
  /// the statement's table placed at [weight], re-typed so each affected
  /// row decodes as [R].
  ///
  /// The seam for driver features that make a write statement yield rows
  /// (`RETURNING`, `OUTPUT`, ...): the driver owns the clause text and its
  /// placement, core owns the re-typing.
  InsertWithValuesBuilder<S, R, R> yieldingRows(
    int weight,
    Clause Function(Table<Schema<dynamic>, dynamic> table) clause,
  ) =>
      InsertWithValuesBuilder(
        executor,
        config: config.addClause(weight, clause(config.into!)),
      );
}

/// Adds [yieldingRows] to an update builder.
extension UpdateYieldingRows<S extends Schema<R>, R>
    on UpdateWhereBuilder<S, R, void> {
  /// The update form of `yieldingRows`, see the insert variant for the
  /// contract.
  UpdateWhereBuilder<S, R, R> yieldingRows(
    int weight,
    Clause Function(Table<Schema<dynamic>, dynamic> table) clause,
  ) =>
      UpdateWhereBuilder(
        executor,
        config: config.addClause(weight, clause(config.table!)),
      );
}

/// Adds [yieldingRows] to a delete builder.
extension DeleteYieldingRows<S extends Schema<R>, R>
    on DeleteWhereBuilder<S, R, void> {
  /// The delete form of `yieldingRows`, see the insert variant for the
  /// contract.
  DeleteWhereBuilder<S, R, R> yieldingRows(
    int weight,
    Clause Function(Table<Schema<dynamic>, dynamic> table) clause,
  ) =>
      DeleteWhereBuilder(
        executor,
        config: config.addClause(weight, clause(config.from!)),
      );
}
