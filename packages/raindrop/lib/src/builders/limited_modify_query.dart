/// Mixin for UPDATE/DELETE queries that may carry a row [limit].
///
/// [BaseSqlDialect] emits `LIMIT` when translating if [limit] is non-null.
mixin LimitedModifyQuery {
  /// When non-null, caps how many rows the statement may affect.
  int? get limit;
}
