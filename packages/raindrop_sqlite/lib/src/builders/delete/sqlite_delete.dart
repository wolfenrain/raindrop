import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping a `DELETE`.
extension SQLiteDeleteLimit<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  /// Cap how many rows the delete affects.
  ///
  /// Rendered as `DELETE ... LIMIT` where the library parses it and as a
  /// primary-key subquery where it does not — see [LimitedWriteClause].
  /// `SQLiteDelegate` settles which by asking the library it was handed.
  DeleteWhereBuilder<S, R, V> limit(int limit) => limitingRows(
        DeleteSlot.where,
        (table, where) =>
            LimitedWriteClause(table: table, filter: where, limit: limit),
      );
}
