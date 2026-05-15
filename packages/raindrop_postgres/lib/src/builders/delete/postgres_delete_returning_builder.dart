import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresDeleteReturningBuilder<S extends Schema<R>, R, V>
    extends DeleteWhereBuilder<S, R, V> {
  PostgresDeleteReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Delete<S, R, V> toQuery() {
    return PostgresDelete(
      from: config.get(#from)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning)!,
    );
  }
}

extension PostgresDeleteReturningExtension<S extends Schema<R>, R>
    on DeleteWhereBuilder<S, R, void> {
  PostgresDeleteReturningBuilder<S, R, R> returning() {
    return PostgresDeleteReturningBuilder<S, R, R>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
