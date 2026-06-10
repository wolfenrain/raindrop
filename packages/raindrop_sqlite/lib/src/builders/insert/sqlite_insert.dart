import 'package:raindrop/dialect.dart';

/// Adds `insertOrIgnore` for SQLite, which skips rows that would violate a
/// constraint instead of failing.
extension SQLiteInsertOrIgnore on RaindropExecutor<RaindropDelegate> {
  /// Like `insert`, but skips rows that would violate a constraint instead of
  /// failing.
  InsertValuesBuilder<Schema<R>, R, void> insertOrIgnore<R>({
    required Schema<R> into,
  }) =>
      insert<R>(into: into)
          .withClause(InsertSlot.verb + 500, const Keyword('OR IGNORE'));
}
