import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping an `UPDATE`.
extension SQLiteUpdateLimit<S extends Schema<R>, R, V>
    on UpdateWhereBuilder<S, R, V> {
  /// Cap how many rows the update affects.
  ///
  /// Rendered as `UPDATE ... LIMIT` where the library parses it and as a
  /// primary-key subquery where it does not — see [LimitedWriteClause].
  /// `SQLiteDelegate` settles which by asking the library it was handed.
  UpdateWhereBuilder<S, R, V> limit(int limit) => limitingRows(
        UpdateSlot.where,
        (table, where) =>
            LimitedWriteClause(table: table, filter: where, limit: limit),
      );
}
