// import 'dart:async';

// import 'package:raindrop/raindrop.dart';

// abstract class Query<E extends Entity<E>, V> {
//   const Query(this.from);

//   final TableDefinition<E> from;
// }

// class QueryConfig<E extends Entity<E>> {
//   const QueryConfig(this.executor, this.from);

//   final RaindropExecutor executor;

//   final TableDefinition<E> from;
// }

// // class PreparedStatement<V>  {
// //   PreparedStatement(this._executor, this._sql, this.name);

// //   final String name;

// //   final RaindropExecutor _executor;

// //   final String _sql;

// //   @override
// //   Future<List<V>> execute() {
// //     _executor.execute('query', values)
// //     // TODO: implement toFuture
// //     throw UnimplementedError();
// //   }
// // }

// abstract class QueryBuilder<Q extends Query<E, V>, C extends QueryConfig<E>,
//     E extends Entity<E>, V> with CachedFuture<List<V>> {
//   QueryBuilder({required this.config});

//   final C config;

//   Q toQuery();

//   // PreparedStatement<V> prepared(String name) {
//   //   final query = toQuery();
//   //   final (sql, values) = config.executor.delegate.dialect.translate(query);
//   //   return PreparedStatement(config.executor, sql);
//   // }

//   @override
//   Future<List<V>> toFuture() => config.executor.query(toQuery());

//   String toString() => config.executor.delegate.dialect.translate(toQuery()).
// $1;
// }
