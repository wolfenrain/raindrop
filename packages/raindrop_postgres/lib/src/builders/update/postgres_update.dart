import 'package:raindrop/raindrop.dart';

export 'postgres_update_returning_builder.dart';
export 'postgres_update_setting_builder.dart';

/// {@template postgres_update}
/// SQL update statement tailored for Postgres.
/// {@endtemplate}
class PostgresUpdate<S extends Schema<S>, V> extends Update<S, V> {
  /// {@macro postgres_update}
  PostgresUpdate({
    required super.set,
    required super.table,
    super.where,
    this.withReturning = false,
  });

  /// Indicates that this insert statement should return it's values or not.
  final bool withReturning;
}
