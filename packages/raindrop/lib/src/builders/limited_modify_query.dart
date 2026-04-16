/// Mixin for UPDATE/DELETE queries that may carry a row [limit].
///
/// Dialects that support this (e.g. SQLite 3.35+) should set
/// [BaseSqlDialect.supportsLimitOnModify] and emit `LIMIT` in translation.
mixin LimitedModifyQuery {
  /// When non-null, caps how many rows the statement may affect.
  int? get limit;
}
