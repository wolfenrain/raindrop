import 'package:raindrop/raindrop.dart';

export 'postgres_update_returning_builder.dart';
export 'postgres_update_setting_builder.dart';

/// {@template postgres_update}
/// SQL update statement tailored for Postgres.
/// {@endtemplate}
class PostgresUpdate<S extends Schema<S>, V> extends Update<S, V>
    with ReturningQuery {
  /// {@macro postgres_update}
  PostgresUpdate({
    required super.set,
    required super.table,
    super.where,
    this.withReturning = false,
  });

  @override
  final bool withReturning;
}
