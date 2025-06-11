import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteUpdateSettingBuilder<S extends Schema<S>, R>
    extends UpdateSettingBuilder<S, R> {
  SQLiteUpdateSettingBuilder(super.executor, {required super.config});

  @override
  UpdateWhereBuilder<S, V, R> set<V>(Updateable<S, V> set) {
    return SQLiteUpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: set}),
    );
  }
}

class SQLiteUpdateWhereBuilder<S extends Schema<S>, V, R>
    extends UpdateWhereBuilder<S, V, R> {
  SQLiteUpdateWhereBuilder(super.executor, {required super.config});

  @override
  Update<S, R> toQuery() {
    return SQLiteUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning)!,
    );
  }
}

// TODO(wolfen): better return type
extension PostgresUpdateReturningExtension<S extends Schema<S>, V>
    on UpdateWhereBuilder<S, V, void> {
  SQLiteUpdateReturningBuilder<S, V> returning() {
    return SQLiteUpdateReturningBuilder<S, V>(
      executor,
      config: config.copyWith({#withReturning: true}),
    );
  }
}
