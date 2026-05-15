import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresInsertReturningBuilder<S extends Schema<R>, R, V>
    extends PostgresInsertWithValuesBuilder<S, R, V> {
  PostgresInsertReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, R, V> toQuery() {
    return PostgresInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning)!,
    );
  }
}
