import 'dart:async';

import 'package:meta/meta.dart';
import 'package:raindrop/dialect.dart';

/// Everything a builder has accumulated so far, keyed by symbol.
extension type const QueryConfig._(Map<Symbol, Object?> _map) {
  /// A config seeded with [entries].
  QueryConfig.from(Map<Symbol, Object?> entries) : this._(entries);

  /// Clone the config, with [entries] merged over it.
  QueryConfig copyWith([Map<Symbol, Object?> entries = const {}]) {
    return QueryConfig._({..._map, ...entries});
  }

  /// Get the value associated by [key].
  V? get<V>(Symbol key) => _map[key] as V?;

  /// Returns a clone with [build] merged into [extras] at [weight]
  /// (replacing any clause already at that weight).
  QueryConfig addClause(
    int weight,
    Clause Function(QueryConfig config) build,
  ) =>
      copyWith({
        #extras: {...?extras, weight: build},
      });

  /// The table a select reads from, and a delete removes from.
  Table<Schema<dynamic>, dynamic>? get from =>
      _map[#from] as Table<Schema<dynamic>, dynamic>?;

  /// The table an insert writes into.
  Table<Schema<dynamic>, dynamic>? get into =>
      _map[#into] as Table<Schema<dynamic>, dynamic>?;

  /// The table an update mutates.
  Table<Schema<dynamic>, dynamic>? get table =>
      _map[#table] as Table<Schema<dynamic>, dynamic>?;

  /// What the select projects.
  Selectable<dynamic>? get selecting =>
      _map[#selecting] as Selectable<dynamic>?;

  /// The row filter.
  Filter? get where => _map[#where] as Filter?;

  /// The group filter.
  Filter? get having => _map[#having] as Filter?;

  /// What rows are grouped by, in order.
  List<Selectable<dynamic>> get groupBy =>
      _map[#groupBy] as List<Selectable<dynamic>>? ?? const [];

  /// The sort terms, in order.
  List<OrderBy> get orderBy => _map[#orderBy] as List<OrderBy>? ?? const [];

  /// The registered joins, in order.
  List<Join<Schema<dynamic>, dynamic>> get joins =>
      _map[#joins] as List<Join<Schema<dynamic>, dynamic>>? ?? const [];

  /// The assignments an update applies.
  Updateable<dynamic>? get set => _map[#set] as Updateable<dynamic>?;

  /// The rows an insert carries.
  List<dynamic>? get values => _map[#values] as List<dynamic>?;

  /// The maximum number of rows to return.
  int? get limit => _map[#limit] as int?;

  /// How many rows to skip.
  int? get offset => _map[#offset] as int?;

  /// Whether the select is `SELECT DISTINCT`.
  bool get distinct => _map[#distinct] as bool? ?? false;

  /// Clause factories grafted on beyond the standard slots, keyed by render
  /// weight and built at compile time from the config as it finally stands.
  Map<int, Clause Function(QueryConfig)>? get extras =>
      _map[#extras] as Map<int, Clause Function(QueryConfig)>?;

  /// The [extras], built against this config. Compiles spread this after
  /// their core clauses.
  Map<int, Clause> buildExtras() => (extras ?? const {})
      .map((weight, build) => MapEntry(weight, build(this)));
}

/// {@template query_builder}
/// Abstract class for all query builders.
/// {@endtemplate}
abstract class QueryBuilder<S, V> {
  /// {@macro query_builder}
  QueryBuilder(this.executor, {required this.config});

  /// The executor being used to query the database with.
  @internal
  final RaindropExecutor executor;

  /// The config of the query builder.
  @internal
  final QueryConfig config;

  @override
  String toString() {
    if (this case final ToQuery<S, V> self) {
      return executor.delegate.dialect.translate(self.compile()).$1;
    }
    return super.toString();
  }
}

/// Makes a terminal builder awaitable.
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

  /// Compiles this builder's config into a renderable + decodable statement.
  ///
  /// [qualified] forces column references to carry their table, which a
  /// statement standing on its own does not need but a subquery does: a
  /// correlated one references the outer query's columns, and an unqualified
  /// name there is ambiguous rather than wrong-looking.
  @visibleForTesting
  Query<V> compile({bool qualified = false});

  /// This builder's statement, prepared to sit inside another one.
  ///
  /// [qualified] differs by position, and getting it wrong is quiet rather
  /// than loud. A subquery in a predicate wants it on, so correlated
  /// references name their table. A derived table wants it OFF: qualifying
  /// makes the projection come out aliased (`"users"."name" AS "users__name"`)
  /// and the outer query's `"name"` then matches nothing.
  ///
  /// Exists because [compile] is test-visible only, and embedding is a library
  /// concern rather than a test one.
  @internal
  Query<V> compileEmbedded({bool qualified = false}) =>
      compile(qualified: qualified);

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

  late final Future<List<V>> _cache = executor.run<V>(compile());
}
