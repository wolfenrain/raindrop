import 'package:raindrop/raindrop.dart';

import 'builders/sqlite_limited_query.dart';

/// {@template sqlite_dialect}
/// SQL dialect for the SQLite database.
/// {@endtemplate}
class SQLiteDialect extends BaseSqlDialect {
  /// {@macro sqlite_dialect}
  const SQLiteDialect();

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';

  @override
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
  ) {
    final sql = super.translateDelete(delete, values);
    return _appendLimitBeforeReturning(sql, delete);
  }

  @override
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
  ) {
    final sql = super.translateUpdate(update, values);
    return _appendLimitBeforeReturning(sql, update);
  }

  String _appendLimitBeforeReturning(String sql, Object query) {
    final lim = switch (query) {
      final SQLiteLimitedQuery q => q.limit,
      _ => null,
    };
    if (lim == null) return sql;
    const token = ' RETURNING ';
    final i = sql.indexOf(token);
    if (i >= 0) {
      return '${sql.substring(0, i)} LIMIT $lim${sql.substring(i)}';
    }
    return '$sql LIMIT $lim';
  }
}
