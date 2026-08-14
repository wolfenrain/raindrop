import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping a `DELETE`.
extension SQLiteDeleteLimit<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  /// Cap how many rows the delete affects. Chain it after `where`, like the
  /// SQL it renders — the returned builder cannot be filtered further.
  ///
  /// Rendered as `DELETE ... LIMIT` where the library parses it and as a
  /// primary-key subquery where it does not — see [LimitedWriteClause].
  DeleteLimitedBuilder<S, R, V> limit(int limit) => withClause(
        DeleteSlot.where,
        (config) => LimitedWriteClause(
          table: config.from!,
          filter: config.where,
          limit: limit,
        ),
        DeleteLimitedBuilder.new,
      );
}
