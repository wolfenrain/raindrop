import 'package:raindrop/raindrop.dart';

export 'postgres_insert_returning_builder.dart';
export 'postgres_insert_values_builder.dart';

/// {@template postgres_insert}
/// SQL insert statement tailored for Postgres.
/// {@endtemplate}
class PostgresInsert<S extends Schema<R>, R, V> extends Insert<S, R, V>
    with ReturningQuery {
  /// {@macro postgres_insert}
  PostgresInsert({
    required super.into,
    required super.values,
    this.withReturning = false,
  });

  @override
  final bool withReturning;
}
