import 'package:raindrop/raindrop.dart';

export 'postgres_delete_returning_builder.dart';

/// {@template postgres_delete}
/// SQL delete statement tailored for Postgres.
/// {@endtemplate}
class PostgresDelete<S extends Schema<S>, V> extends Delete<S, V>
    with ReturningQuery {
  /// {@macro postgres_delete}
  PostgresDelete({
    required super.from,
    super.where,
    this.withReturning = false,
  });

  @override
  final bool withReturning;
}
