import 'package:raindrop/dialect.dart';

/// SQLite supports `LIMIT` on `DELETE`.
extension SQLiteDeleteLimit<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  /// Cap how many rows the delete affects.
  DeleteWhereBuilder<S, R, V> limit(int limit) =>
      withClause(DeleteSlot.where + 1000, LimitClause(limit));
}
