import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresInsertValuesBuilder<S extends Schema<S>, V>
    extends InsertValuesBuilder<S, V> {
  PostgresInsertValuesBuilder(super.executor, {required super.config});

  // TODO: only on non inserted builder!
  @override
  InsertWithValuesBuilder<S, V> values(List<S> values) {
    return PostgresInsertWithValuesBuilder(
      executor,
      config: config.copyWith({
        #values: [...values],
      }),
    );
  }
}

class PostgresInsertWithValuesBuilder<S extends Schema<S>, V>
    extends InsertWithValuesBuilder<S, V> {
  PostgresInsertWithValuesBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, V> toQuery() {
    return PostgresInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}

extension PostgresInsertReturningExtension<S extends Schema<S>>
    on InsertWithValuesBuilder<S, void> {
  PostgresInsertReturningBuilder<S, S> returning() {
    return PostgresInsertReturningBuilder<S, S>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
