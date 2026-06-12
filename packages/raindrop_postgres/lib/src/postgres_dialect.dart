import 'package:raindrop/dialect.dart';

/// {@template postgres_dialect}
/// SQL dialect for the Postgres database.
/// {@endtemplate}
class PostgresDialect extends SqlDialect {
  /// {@macro postgres_dialect}
  const PostgresDialect();

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';
}
