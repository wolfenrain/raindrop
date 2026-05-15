import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresUpdateReturningBuilder<S extends Schema<R>, R, ST, V>
    extends UpdateWhereBuilder<S, R, ST, V> {
  PostgresUpdateReturningBuilder(super.executor, {required super.config});

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
