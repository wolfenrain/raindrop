import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteDeleteReturningBuilder<S extends Schema<R>, R, V>
    extends DeleteWhereBuilder<S, R, V> {
  SQLiteDeleteReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Delete<S, R, V> toQuery() {
    return SQLiteDelete(
      from: config.get(#from)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) as bool? ?? false,
      limit: config.get(#limit) as int?,
    );
  }
}

extension SQLiteDeleteLimitExtension<S extends Schema<R>, R, V>
    on DeleteWhereBuilder<S, R, V> {
  SQLiteDeleteReturningBuilder<S, R, V> limit(int limit) {
    return SQLiteDeleteReturningBuilder(
      executor,
      config: config.copyWith({#limit: limit}),
    );
  }
}

extension SQLiteDeleteReturningExtension<S extends Schema<R>, R>
    on DeleteWhereBuilder<S, R, void> {
  SQLiteDeleteReturningBuilder<S, R, R> returning() {
    return SQLiteDeleteReturningBuilder<S, R, R>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
