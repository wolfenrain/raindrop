import 'package:raindrop/raindrop.dart';

/// {@template sqlite_dialect}
/// SQL dialect for the SQLite database.
/// {@endtemplate}
class SQLiteDialect extends BaseSqlDialect {
  /// {@macro sqlite_dialect}
  const SQLiteDialect();

  @override
  bool get supportsLimitOnModify => true;

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';
}
