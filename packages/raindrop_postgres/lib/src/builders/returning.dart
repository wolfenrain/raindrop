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
extension PostgresInsertReturning<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the insert yields the stored rows.
  InsertWithValuesBuilder<S, R, R> returning() =>
      yieldingRows(InsertSlot.body + 5000, ReturningClause.new);
}

/// Adds `.returning()` to an update.
extension PostgresUpdateReturning<S extends Schema<R>, R>
    on UpdateWhereBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the update yields the changed rows.
  UpdateWhereBuilder<S, R, R> returning() =>
      yieldingRows(UpdateSlot.where + 5000, ReturningClause.new);
}

/// Adds `.returning()` to a delete.
extension PostgresDeleteReturning<S extends Schema<R>, R>
    on DeleteWhereBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`, so the delete yields the removed rows.
  DeleteWhereBuilder<S, R, R> returning() =>
      yieldingRows(DeleteSlot.where + 5000, ReturningClause.new);
}
