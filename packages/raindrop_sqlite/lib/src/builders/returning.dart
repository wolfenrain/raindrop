import 'package:raindrop/dialect.dart';

/// `RETURNING <selection>` for this driver's writes (whole-row by table).
class ReturningClause extends Clause {
  /// Creates a returning clause for a [selectable] (typically the table).
  const ReturningClause(this.selectable);

  /// What to return.
  final Selectable<dynamic> selectable;

  @override
  String render(RenderContext context) =>
      'RETURNING ${SelectionClause(selectable).render(context)}';
}

/// Adds `.returning()` to an insert.
extension SQLiteInsertReturning<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the insert yields the stored rows.
  InsertWithValuesBuilder<S, R, R> returning() => withClause(
        InsertSlot.body + 5000,
        (config) => ReturningClause(config.into!),
        InsertWithValuesBuilder.new,
      );
}

/// Adds `.returning()` to an update.
extension SQLiteUpdateReturning<S extends Schema<R>, R>
    on UpdateWhereBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the update yields the changed rows.
  UpdateWhereBuilder<S, R, R> returning() => withClause(
        UpdateSlot.where + 5000,
        (config) => ReturningClause(config.table!),
        UpdateWhereBuilder.new,
      );
}

/// Adds `.returning()` to a delete.
extension SQLiteDeleteReturning<S extends Schema<R>, R>
    on DeleteWhereBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the delete yields the removed rows.
  DeleteWhereBuilder<S, R, R> returning() => withClause(
        DeleteSlot.where + 5000,
        (config) => ReturningClause(config.from!),
        DeleteWhereBuilder.new,
      );
}

/// Adds `.returning()` to a capped update.
extension SQLiteUpdateLimitedReturning<S extends Schema<R>, R>
    on UpdateLimitedBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the update yields the changed rows.
  UpdateLimitedBuilder<S, R, R> returning() => withClause(
        UpdateSlot.where + 5000,
        (config) => ReturningClause(config.table!),
        UpdateLimitedBuilder.new,
      );
}

/// Adds `.returning()` to a capped delete.
extension SQLiteDeleteLimitedReturning<S extends Schema<R>, R>
    on DeleteLimitedBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the delete yields the removed rows.
  DeleteLimitedBuilder<S, R, R> returning() => withClause(
        DeleteSlot.where + 5000,
        (config) => ReturningClause(config.from!),
        DeleteLimitedBuilder.new,
      );
}
