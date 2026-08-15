import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/builders/limited_write.dart';

/// SQLite supports capping a `DELETE`.
extension SQLiteDeleteLimit<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  /// Cap how many rows the delete affects.
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
