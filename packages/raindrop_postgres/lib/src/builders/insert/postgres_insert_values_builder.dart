import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresInsertValuesBuilder<S extends Schema<R>, R, V>
    extends InsertValuesBuilder<S, R, V> {
  PostgresInsertValuesBuilder(super.executor, {required super.config});

  // TODO: only on non inserted builder!
  @override
  InsertWithValuesBuilder<S, R, V> values(List<R> values) {
    return PostgresInsertWithValuesBuilder(
      executor,
      config: config.copyWith({
        #values: [...values],
      }),
    );
  }
}

class PostgresInsertWithValuesBuilder<S extends Schema<R>, R, V>
    extends InsertWithValuesBuilder<S, R, V> {
  PostgresInsertWithValuesBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, R, V> toQuery() {
    return PostgresInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}

extension PostgresInsertReturningExtension<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  PostgresInsertReturningBuilder<S, R, R> returning() {
    return PostgresInsertReturningBuilder<S, R, R>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
