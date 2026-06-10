import 'package:raindrop/raindrop.dart';

/// Joins for an explicit column projection (`select(colA, colB, ...)`).
///
/// Unlike the whole-row joins (which append the joined table to the result
/// tuple), these keep the explicit projection [V] intact and only register the
/// JOIN clause so you can project specific columns, aggregates, and columns
/// from the joined table(s) in a single query:
///
/// ```dart
/// db
///   .select(runs.userId, min(runs.solveMs), users.displayName)
///   .from(runs)
///   .join(users, on: runs.userId.equals(users.id))
///   .groupBy(runs.userId);
/// // SELECT "runs"."user_id", MIN("runs"."solve_ms"), "users"."display_name"
/// // FROM "runs" INNER JOIN "users" ON ... GROUP BY "runs"."user_id"
/// ```
///
/// A single extension covers every projection arity because `.join` does not
/// change [V] — there is no per-arity machinery here.
extension ProjectionJoins<S extends Schema<R>, R, V>
    on ProjectionFromBuilder<S, R, V> {
  /// Add an `INNER JOIN` against [table] without altering the projection.
  ProjectionFromBuilder<S, R, V> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) =>
      _withJoin(InnerJoin<Schema<OR>, OR>(_table(table), on: on));

  /// Add a `LEFT JOIN` against [table] without altering the projection.
  ProjectionFromBuilder<S, R, V> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) =>
      _withJoin(LeftJoin<Schema<OR>, OR>(_table(table), on: on));

  /// Add a `RIGHT JOIN` against [table] without altering the projection.
  ProjectionFromBuilder<S, R, V> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) =>
      _withJoin(RightJoin<Schema<OR>, OR>(_table(table), on: on));

  Table<Schema<OR>, OR> _table<OR>(Schema<OR> table) =>
      Table.get(table)! as Table<Schema<OR>, OR>;

  ProjectionFromBuilder<S, R, V> _withJoin(Join join) {
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[...config.get(#joins) ?? [], join],
      }),
    );
  }
}
