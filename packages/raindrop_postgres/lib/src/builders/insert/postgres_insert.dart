import 'package:raindrop/raindrop.dart';

export 'postgres_insert_returning_builder.dart';
export 'postgres_insert_values_builder.dart';

/// {@template postgres_insert}
/// SQL insert statement tailored for Postgres.
/// {@endtemplate}
class PostgresInsert<S extends Schema<S>, V> extends Insert<S, V> {
  /// {@macro postgres_insert}
  PostgresInsert({
    required super.into,
    required super.values,
    this.withReturning = false,
  });

  /// Indicates that this insert statement should return it's values or not.
  final bool withReturning;
}
