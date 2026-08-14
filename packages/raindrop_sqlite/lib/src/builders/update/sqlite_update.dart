import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping an `UPDATE`.
extension SQLiteUpdateLimit<S extends Schema<R>, R, V>
    on UpdateWhereBuilder<S, R, V> {
  /// Cap how many rows the update affects.
  UpdateLimitedBuilder<S, R, V> limit(int limit) => withClause(
        UpdateSlot.where,
        (config) => LimitedWriteClause(
          table: config.table!,
          filter: config.where,
          limit: limit,
        ),
        UpdateLimitedBuilder.new,
      );
}
