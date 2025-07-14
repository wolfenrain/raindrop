import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresUpdateReturningBuilder<S extends Schema<S>, V, R>
    extends UpdateWhereBuilder<S, V, R> {
  PostgresUpdateReturningBuilder(super.executor, {required super.config});

  @override
  Update<S, R> toQuery() {
    return PostgresUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}
