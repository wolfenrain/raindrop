import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/rendering/clause.dart';

/// The extension that grafts [QueryConfig.extras] onto builders.
extension Extras<S, V> on QueryBuilder<S, V> {
  /// Returns this builder copied via [create], with the clause built by
  /// [build] placed at [weight].
  ///
  /// [build] runs at compile time against the config as it finally stands,
  /// so call order cannot change the SQL. Pass a core slot's own weight to
  /// replace that clause rather than emit a second one.
  ///
  /// [create] names the builder the chain continues as. A driver hands a
  /// different one to change what the chain allows from there: re-typing
  /// a write so it yields rows (`RETURNING`, `OUTPUT`, ...), sealing the
  /// filter behind a row cap (`LIMIT`, `TOP`, ...).
  B withClause<B extends QueryBuilder<dynamic, dynamic>>(
    int weight,
    Clause Function(QueryConfig config) build,
    B Function(RaindropExecutor executor, {required QueryConfig config}) create,
  ) =>
      create(executor, config: config.addClause(weight, build));
}
