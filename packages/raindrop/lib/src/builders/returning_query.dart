/// Mixin for queries that support RETURNING clause.
mixin ReturningQuery {
  /// Whether this query should return values.
  bool get withReturning;
}
