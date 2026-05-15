import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteUpdateReturningBuilder<S extends Schema<R>, R, ST, V>
    extends UpdateWhereBuilder<S, R, ST, V> {
  SQLiteUpdateReturningBuilder(super.executor, {required super.config});

  @override
  Update<S, R, V> toQuery() {
    return SQLiteUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) ?? false,
      limit: config.get(#limit) as int?,
    );
  }
}

extension SQLiteUpdateLimitExtension<S extends Schema<R>, R, ST, V>
    on UpdateWhereBuilder<S, R, ST, V> {
  SQLiteUpdateReturningBuilder<S, R, ST, V> limit(int limit) {
    return SQLiteUpdateReturningBuilder(
      executor,
      config: config.copyWith({#limit: limit}),
    );
  }
}
