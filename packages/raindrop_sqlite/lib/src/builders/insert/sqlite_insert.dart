import 'package:raindrop/raindrop.dart';

export 'sqlite_insert_returning_builder.dart';
export 'sqlite_insert_values_builder.dart';

/// {@template sqlite_insert}
/// SQL insert statement tailored for SQLite.
/// {@endtemplate}
class SQLiteInsert<S extends Schema<S>, V> extends Insert<S, V>
    with ReturningQuery {
  /// {@macro sqlite_insert}
  SQLiteInsert({
    required super.into,
    required super.values,
    this.withReturning = false,
  });

  @override
  final bool withReturning;
}
