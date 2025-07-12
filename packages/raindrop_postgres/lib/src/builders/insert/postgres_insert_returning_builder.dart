import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresInsertReturningBuilder<S extends Schema<S>, V>
    extends PostgresInsertWithValuesBuilder<S, V> {
  PostgresInsertReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, V> toQuery() {
    return PostgresInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning)!,
    );
  }
}
