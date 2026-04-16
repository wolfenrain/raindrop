import 'package:raindrop/raindrop.dart';

import '../sqlite_limited_query.dart';

export 'sqlite_delete_returning_builder.dart';

/// {@template sqlite_delete}
/// SQL delete statement tailored for SQLite.
/// {@endtemplate}
class SQLiteDelete<S extends Schema<S>, V> extends Delete<S, V>
    with ReturningQuery, SQLiteLimitedQuery {
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
