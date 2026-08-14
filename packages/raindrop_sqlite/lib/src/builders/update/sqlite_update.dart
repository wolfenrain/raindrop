import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping an `UPDATE`.
extension SQLiteUpdateLimit<S extends Schema<R>, R, V>
    on UpdateWhereBuilder<S, R, V> {
  /// Cap how many rows the update affects. Chain it after `where`, like the
  /// SQL it renders — the returned builder cannot be filtered further.
  ///
  /// Rendered as `UPDATE ... LIMIT` where the library parses it and as a
  /// primary-key subquery where it does not — see [LimitedWriteClause].
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
