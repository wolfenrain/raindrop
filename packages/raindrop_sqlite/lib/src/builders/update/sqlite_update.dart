import 'package:raindrop/raindrop.dart';

export 'sqlite_update_returning_builder.dart';
export 'sqlite_update_setting_builder.dart';

/// {@template sqlite_update}
/// SQL update statement tailored for SQLite.
/// {@endtemplate}
class SQLiteUpdate<S extends Schema<S>, V> extends Update<S, V>
    with ReturningQuery, LimitedModifyQuery {
  /// {@macro sqlite_update}
  SQLiteUpdate({
    required super.set,
    required super.table,
    super.where,
    this.withReturning = false,
    this.limit,
  });

  @override
  final bool withReturning;

  @override
  final int? limit;
}
