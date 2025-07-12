import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresUpdateSettingBuilder<S extends Schema<S>, R>
    extends UpdateSettingBuilder<S, R> {
  PostgresUpdateSettingBuilder(super.executor, {required super.config});

  @override
  UpdateWhereBuilder<S, V, R> set<V>(Updateable<S, V> set) {
    return PostgresUpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: set}),
    );
  }
}

class PostgresUpdateWhereBuilder<S extends Schema<S>, V, R>
    extends UpdateWhereBuilder<S, V, R> {
  PostgresUpdateWhereBuilder(super.executor, {required super.config});

  @override
  Update<S, R> toQuery() {
    return PostgresUpdate(
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
  PostgresUpdateReturningBuilder<S, V, S> returning() {
    return PostgresUpdateReturningBuilder<S, V, S>(
      executor,
      config: config.copyWith({#withReturning: true}),
    );
  }
}
