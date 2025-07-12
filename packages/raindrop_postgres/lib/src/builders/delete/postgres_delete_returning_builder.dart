import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class PostgresDeleteReturningBuilder<S extends Schema<S>, V>
    extends DeleteWhereBuilder<S, V> {
  PostgresDeleteReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Delete<S, V> toQuery() {
    return PostgresDelete(
      from: config.get(#from)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning)!,
    );
  }
}

extension PostgresDeleteReturningExtension<S extends Schema<S>>
    on DeleteWhereBuilder<S, void> {
  PostgresDeleteReturningBuilder<S, S> returning() {
    return PostgresDeleteReturningBuilder<S, S>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
