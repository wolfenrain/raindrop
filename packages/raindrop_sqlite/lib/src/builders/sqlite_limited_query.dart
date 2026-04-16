/// SQLite-specific [Query] metadata (SQLite 3.35+).
mixin SQLiteLimitedQuery {
  /// When non-null, adds `LIMIT` after `WHERE` (and before `RETURNING`).
  int? get limit;
}
