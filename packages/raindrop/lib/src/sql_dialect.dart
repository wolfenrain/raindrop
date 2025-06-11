import 'package:raindrop/raindrop.dart';

/// {@template sql_dialect}
/// Base class for supporting any kind of SQL dialect.
/// {@endtemplate}
abstract class SqlDialect {
  /// {@macro sql_dialect}
  const SqlDialect();

  /// Translate [query] into a query statement with values.
  (String, List<Object?>) translate<S extends Schema<S>, V>(
    Query<S, V> query,
    AliasRegistry<S, V> registry,
  ) {
    return Raindrop.tracer.trace('$runtimeType.translate', (span) {
      final values = <Object?>[];
      final sql = switch (query) {
        Insert<S, V>() => translateInsert(query, values, registry),
        Select<S, V>() => translateSelect(query, values, registry),
        Update<S, V>() => translateUpdate(query, values, registry),
        Delete<S, V>() => translateDelete(query, values, registry),
        _ => throw UnsupportedError('${query.runtimeType}'),
      };

      span?.attributes.addAll({'sql': sql, 'values': values});

      return (sql, values);
    });
  }

  /// Translate an [insert].
  String translateInsert<S extends Schema<S>, V>(
    Insert<S, V> insert,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  );

  /// Translate a [select].
  String translateSelect<S extends Schema<S>, V>(
    Select<S, V> select,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  );

  /// Translate an [update].
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  );

  /// Translate a [delete].
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  );

  /// Translate a [filter].
  String translateFilter(
    Filter filter,
    List<Object?> values,
    AliasRegistry registry, [
    int level = 0,
  ]);
}
