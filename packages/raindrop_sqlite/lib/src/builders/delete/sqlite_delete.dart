import 'package:raindrop/raindrop.dart';

export 'sqlite_delete_returning_builder.dart';

/// {@template sqlite_delete}
/// SQL delete statement tailored for SQLite.
/// {@endtemplate}
class SQLiteDelete<S extends Schema<R>, R, V> extends Delete<S, R, V>
    with ReturningQuery, LimitedModifyQuery {
  /// {@macro sqlite_delete}
  SQLiteDelete({
    required super.from,
    super.where,
    this.withReturning = false,
    this.limit,
  });

  @override
  final bool withReturning;

  @override
  final int? limit;
}
