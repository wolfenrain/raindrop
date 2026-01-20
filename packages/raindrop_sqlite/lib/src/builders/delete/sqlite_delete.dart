import 'package:raindrop/raindrop.dart';

export 'sqlite_delete_returning_builder.dart';

/// {@template sqlite_delete}
/// SQL delete statement tailored for SQLite.
/// {@endtemplate}
class SQLiteDelete<S extends Schema<S>, V> extends Delete<S, V>
    with ReturningQuery {
  /// {@macro sqlite_delete}
  SQLiteDelete({
    required super.from,
    super.where,
    this.withReturning = false,
  });

  @override
  final bool withReturning;
}
