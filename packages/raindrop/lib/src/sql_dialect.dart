import 'package:raindrop/raindrop.dart';

/// {@template sql_dialect}
/// Base class for supporting any kind of SQL dialect.
/// {@endtemplate}
abstract class SqlDialect {
  /// {@macro sql_dialect}
  const SqlDialect();

  /// Translate [query] into a query statement with values.
  (String, List<Object?>) translate<S extends Schema<S>, V>(Query<S, V> query) {
    return Raindrop.tracer.trace('$runtimeType.translate', (span) {
      final values = <Object?>[];
      final sql = switch (query) {
        Insert<S, V>() => translateInsert(query, values),
        Select<S, V>() => translateSelect(query, values),
        Update<S, V>() => translateUpdate(query, values),
        Delete<S, V>() => translateDelete(query, values),
        _ => throw UnsupportedError('${query.runtimeType}'),
      };

      span?.attributes.addAll({'sql': sql, 'values': values});

      return (sql, values);
    });
  }

  /// Escape the [name] for SQL consumption.
  String escapeName(String name);

  /// Escape the [number] for SQL consumption.
  String escapeParam(int number);

  /// Translate an [insert].
  String translateInsert<S extends Schema<S>, V>(
    Insert<S, V> insert,
    List<Object?> values,
  );

  /// Translate a [select].
  String translateSelect<S extends Schema<S>, V>(
    Select<S, V> select,
    List<Object?> values,
  );

  /// Translate an [update].
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
  );

  /// Translate a [delete].
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
  );

  /// Translate a [filter].
  String translateFilter(
    Filter filter,
    List<Object?> values, {
    bool singleTable = false,
    int level = 0,
  });

  /// Ensures that the migration tracking storage exists.
  ///
  /// Use [execute] to run any necessary setup queries.
  Future<void> ensureMigrationStorage(
    Future<DatabaseResult> Function(String sql, [List<Object?> values]) execute,
  );

  /// Loads all previously applied migrations.
  ///
  /// Must return a list of `(tag, checksum)` pairs, ordered by application
  /// order.
  Future<List<({String tag, String checksum})>> loadAppliedMigrations(
    Future<DatabaseResult> Function(String sql, [List<Object?> values]) execute,
  );

  /// Records a migration as applied.
  ///
  /// Called after a migration has been successfully executed within
  /// a transaction. Use [execute] to persist the record.
  Future<void> recordMigration(
    Future<DatabaseResult> Function(String sql, [List<Object?> values]) execute,
    {required String tag,
    required String checksum,}
  );
}
