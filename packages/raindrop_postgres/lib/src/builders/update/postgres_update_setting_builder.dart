import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresUpdateSettingBuilder<S extends Schema<R>, R, V>
    extends UpdateSettingBuilder<S, R, V> {
  PostgresUpdateSettingBuilder(super.executor, {required super.config});
}

class PostgresUpdateWhereBuilder<S extends Schema<R>, R, ST, V>
    extends UpdateWhereBuilder<S, R, ST, V> {
  PostgresUpdateWhereBuilder(super.executor, {required super.config});

  @override
  Update<S, R, V> toQuery() {
    return PostgresUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}

extension PostgresUpdateReturningExtension<S extends Schema<R>, R, ST>
    on UpdateWhereBuilder<S, R, ST, void> {
  PostgresUpdateReturningBuilder<S, R, ST, R> returning() {
    return PostgresUpdateReturningBuilder<S, R, ST, R>(
      executor,
      config: config.copyWith({#withReturning: true}),
    );
  }
}
