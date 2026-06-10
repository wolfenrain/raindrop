import 'package:raindrop/dialect.dart';

/// SQLite supports `LIMIT` on `UPDATE`.
extension SQLiteUpdateLimit<S extends Schema<R>, R, V>
    on UpdateWhereBuilder<S, R, V> {
  /// Cap how many rows the update affects.
  UpdateWhereBuilder<S, R, V> limit(int limit) =>
      withClause(UpdateSlot.where + 1000, LimitClause(limit));
}
