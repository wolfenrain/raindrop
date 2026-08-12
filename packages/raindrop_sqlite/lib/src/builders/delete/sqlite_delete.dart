import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping a `DELETE`.
extension SQLiteDeleteLimit<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  /// Cap how many rows the delete affects.
  ///
  /// Rendered as a primary-key subquery rather than `DELETE ... LIMIT`, which
  /// only parses on SQLite builds compiled with
  /// `SQLITE_ENABLE_UPDATE_DELETE_LIMIT` — see [LimitedWriteClause].
  DeleteWhereBuilder<S, R, V> limit(int limit) => limitingRows(
        DeleteSlot.where,
        (table, where) =>
            LimitedWriteClause(table: table, filter: where, limit: limit),
      );
}
