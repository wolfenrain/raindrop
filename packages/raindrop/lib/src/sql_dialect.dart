import 'package:raindrop/raindrop.dart';

/// {@template sql_dialect}
/// Base class for supporting any kind of SQL dialect.
/// {@endtemplate}
abstract class SqlDialect {
  /// {@macro sql_dialect}
  const SqlDialect();

  /// Translate [query] into a query statement with values.
  (String, List<Object?>) translate<S, V>(Query<S, V> query) {
    return Raindrop.tracer.trace('$runtimeType.translate', (span) {
      final values = <Object?>[];
      final sql = switch (query) {
        final Insert q => translateInsert(q, values),
        final Select q => translateSelect(q, values),
        final Update q => translateUpdate(q, values),
        final Delete q => translateDelete(q, values),
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
  String translateInsert(Insert insert, List<Object?> values);

  /// Translate a [select].
  String translateSelect(Select select, List<Object?> values);

  /// Translate an [update].
  String translateUpdate(Update update, List<Object?> values);

  /// Translate a [delete].
  String translateDelete(Delete delete, List<Object?> values);

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
    Future<DatabaseResult> Function(String sql, [List<Object?> values])
        execute, {
    required String tag,
    required String checksum,
  });
}
