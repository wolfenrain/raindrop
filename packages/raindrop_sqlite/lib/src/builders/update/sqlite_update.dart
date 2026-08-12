import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping an `UPDATE`.
extension SQLiteUpdateLimit<S extends Schema<R>, R, V>
    on UpdateWhereBuilder<S, R, V> {
  /// Cap how many rows the update affects.
  ///
  /// Rendered as a primary-key subquery rather than `UPDATE ... LIMIT`, which
  /// only parses on SQLite builds compiled with
  /// `SQLITE_ENABLE_UPDATE_DELETE_LIMIT` — see [LimitedWriteClause].
  UpdateWhereBuilder<S, R, V> limit(int limit) => limitingRows(
        UpdateSlot.where,
        (table, where) =>
            LimitedWriteClause(table: table, filter: where, limit: limit),
      );
}
