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
abstract class QueryBuilder<S, V> implements Query<S, V> {
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
      return executor.delegate.dialect.translate(query).$1;
    }
    return super.toString();
  }
}

/// Provide the [toQuery] method to a query builder.
mixin ToQuery<S, V> on QueryBuilder<S, V> implements Future<List<V>> {
  /// The first element.
  ///
  /// Throws a [StateError] if `this` is empty.
  /// Otherwise returns the first element in the iteration order,
  /// equivalent to `this.elementAt(0)`.
  Future<V> get first async => (await this).first;

  /// The first element of this iterator, or `null` if the iterable is empty.
  Future<V?> get firstOrNull async => (await this).firstOrNull;

  /// The last element.
  ///
  /// Throws a [StateError] if `this` is empty.
  /// Otherwise may iterate through the elements and returns the last one
  /// seen.
  /// Some iterables may have more efficient ways to find the last element
  /// (for example a list can directly access the last element,
  /// without iterating through the previous ones).
  Future<V> get last async => (await this).last;

  /// The last element of this iterable, or `null` if the iterable is empty.
  Future<V?> get lastOrNull async => (await this).lastOrNull;

  /// Checks that this iterable has only one element, and returns that element.
  ///
  /// Throws a [StateError] if `this` is empty or has more than one element.
  /// This operation will not iterate past the second element.
  Future<V> get single async => (await this).single;

  /// The single element of this iterator, or `null`.
  ///
  /// If the iterator has precisely one element, this is that element.
  /// Otherwise, if the iterator has zero elements, or it has two or more,
  /// the value is `null`.
  Future<V?> get singleOrNull async => (await this).singleOrNull;

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
