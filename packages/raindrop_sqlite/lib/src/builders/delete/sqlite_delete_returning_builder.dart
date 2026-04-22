import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteDeleteReturningBuilder<S extends Schema<S>, V>
    extends DeleteWhereBuilder<S, V> {
  SQLiteDeleteReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Delete<S, V> toQuery() {
    return SQLiteDelete(
      from: config.get(#from)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) as bool? ?? false,
      limit: config.get(#limit) as int?,
    );
  }
}

extension SQLiteDeleteLimitExtension<S extends Schema<S>, V>
    on DeleteWhereBuilder<S, V> {
  SQLiteDeleteReturningBuilder<S, V> limit(int limit) {
    return SQLiteDeleteReturningBuilder(
      executor,
      config: config.copyWith({#limit: limit}),
    );
  }
}

extension SQLiteDeleteReturningExtension<S extends Schema<S>>
    on DeleteWhereBuilder<S, void> {
  SQLiteDeleteReturningBuilder<S, S> returning() {
    return SQLiteDeleteReturningBuilder<S, S>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
