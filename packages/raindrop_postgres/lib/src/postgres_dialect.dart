import 'package:raindrop/raindrop.dart';

/// {@template postgres_dialect}
/// SQL dialect for the Postgres database.
/// {@endtemplate}
class PostgresDialect extends BaseSqlDialect {
  /// {@macro postgres_dialect}
  const PostgresDialect();

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';
}
