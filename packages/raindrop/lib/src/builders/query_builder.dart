import 'dart:async';

import 'package:raindrop/raindrop.dart';

/// Simple map that defines a query config.
typedef QueryConfig = Map<Symbol, Object?>;

/// Provides a clone method for a query config.
extension CloneConfig on QueryConfig {
  /// Clone the query config.
  QueryConfig copyWith([QueryConfig config = const {}]) {
    return {...this, ...config};
  }

  /// Get the value associated by [key] or use the [orElse] value.
  V? get<V>(Symbol key, {V? orElse}) => (this[key] as V?) ?? orElse;
}

/// {@template query_builder}
/// Abstract class for all query builders.
/// {@endtemplate}
abstract class QueryBuilder<S extends Schema<S>, V> implements Query<S, V> {
  /// {@macro query_builder}
  QueryBuilder(this.executor, {required this.config});

  /// The executor being used to query the database with.
  final RaindropExecutor executor;

  /// The config of the query builder.
  final QueryConfig config;

  @override
  String toString() {
    if (this is ToQuery<S, V>) {
      final query = (this as ToQuery<S, V>).toQuery();
      final registry = AliasRegistry(query);
      return executor.delegate.dialect.translate(query, registry).$1;
    }
    return super.toString();
  }
}

/// Provide the [toQuery] method to a query builder.
mixin ToQuery<S extends Schema<S>, V> on QueryBuilder<S, V>
    implements Future<List<V>> {
  /// Turn the builder into a [Query] instance.
  Query<S, V> toQuery();

  @override
  Stream<List<V>> asStream() => _cache.asStream();

  @override
  Future<List<V>> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) {
    return _cache.catchError(onError, test: test);
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<V> value) onValue, {
    Function? onError,
  }) {
    return _cache.then(onValue, onError: onError);
  }

  @override
  Future<List<V>> timeout(
    Duration timeLimit, {
    FutureOr<List<V>> Function()? onTimeout,
  }) {
    return _cache.timeout(timeLimit, onTimeout: onTimeout);
  }

  @override
  Future<List<V>> whenComplete(FutureOr<void> Function() action) {
    return _cache.whenComplete(action);
  }

  late final Future<List<V>> _cache = executor.query(toQuery());
}
