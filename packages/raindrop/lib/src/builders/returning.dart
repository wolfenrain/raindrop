import 'package:raindrop/dialect.dart';

// TODO(wolfen): i dont think we should do this in core but i am lazy rn, do have to clean up

/// Adds `.returning()` to an insert.
extension InsertReturning<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`.
  InsertWithValuesBuilder<S, R, R> returning() {
    return InsertWithValuesBuilder<S, R, R>(
      executor,
      config: config.addClause(
        InsertSlot.body + 5000,
        ReturningClause(config.into!),
      ),
    );
  }
}

/// Adds `.returning()` to an update.
extension UpdateReturning<S extends Schema<R>, R>
    on UpdateWhereBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`.
  UpdateWhereBuilder<S, R, R> returning() {
    return UpdateWhereBuilder<S, R, R>(
      executor,
      config: config.addClause(
        UpdateSlot.where + 5000,
        ReturningClause(config.table!),
      ),
    );
  }
}

/// Adds `.returning()` to a delete.
extension DeleteReturning<S extends Schema<R>, R>
    on DeleteWhereBuilder<S, R, void> {
  /// Append `RETURNING <all columns>`.
  DeleteWhereBuilder<S, R, R> returning() {
    return DeleteWhereBuilder<S, R, R>(
      executor,
      config: config.addClause(
        DeleteSlot.where + 5000,
        ReturningClause(config.from!),
      ),
    );
  }
}
