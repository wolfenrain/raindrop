import 'package:raindrop/dialect.dart';

/// {@template sql_dialect}
/// Base class for any SQL dialect.
///
/// A dialect supplies only the dialect-specific *mechanics* like identifier
/// escaping ([escapeName]) and bind-parameter syntax ([escapeParam]). The SQL
/// itself is assembled from composable [Clause]s produced by each query (see
/// [Query]).
/// {@endtemplate}
abstract class SqlDialect {
  /// {@macro sql_dialect}
  const SqlDialect();

  /// Translate [query] into a SQL statement with its ordered bind values.
  (String, List<Object?>) translate(Query<dynamic> query) {
    return Raindrop.tracer.trace('$runtimeType.translate', (span) {
      final clauses = query.clauses;
      final weights = clauses.keys.toList()..sort();

      final context = RenderContext(this);
      final parts = <String>[];
      for (final weight in weights) {
        final rendered = clauses[weight]!.render(context);
        if (rendered.isNotEmpty) parts.add(rendered);
      }
      final sql = parts.join(' ');
      span?.attributes.addAll({'sql': sql, 'values': context.values});
      return (sql, context.values);
    });
  }

  /// Escape the [name] of a table or column for SQL consumption.
  String escapeName(String name);

  /// The placeholder for the bind parameter at zero-based [number].
  String escapeParam(int number);

  /// Ensures that the migration tracking storage exists.
  Future<void> ensureMigrationStorage(
    Future<DatabaseResult> Function(String sql, [List<Object?> values]) execute,
  ) async {
    final table = escapeName('_raindrop_migrations');
    final id = escapeName('id');
    final tag = escapeName('tag');
    final checksum = escapeName('checksum');
    final appliedAt = escapeName('applied_at');
    await execute(
      'CREATE TABLE IF NOT EXISTS $table '
      '($id INTEGER PRIMARY KEY, '
      '$tag TEXT NOT NULL UNIQUE, '
      '$checksum TEXT NOT NULL, '
      '$appliedAt INTEGER NOT NULL)',
    );
  }

  /// Loads all previously applied migrations, ordered by application order.
  Future<List<({String tag, String checksum})>> loadAppliedMigrations(
    Future<DatabaseResult> Function(String sql, [List<Object?> values]) execute,
  ) async {
    final table = escapeName('_raindrop_migrations');
    final tag = escapeName('tag');
    final checksum = escapeName('checksum');
    final id = escapeName('id');
    final result =
        await execute('SELECT $tag, $checksum FROM $table ORDER BY $id');
    return result.rows.map((row) {
      return (tag: row[0]! as String, checksum: row[1]! as String);
    }).toList();
  }

  /// Records a migration as applied.
  Future<void> recordMigration(
    Future<DatabaseResult> Function(String sql, [List<Object?> values])
        execute, {
    required String tag,
    required String checksum,
  }) async {
    final table = escapeName('_raindrop_migrations');
    final tagCol = escapeName('tag');
    final checksumCol = escapeName('checksum');
    final appliedAt = escapeName('applied_at');
    await execute(
      'INSERT INTO $table ($tagCol, $checksumCol, $appliedAt) '
      'VALUES (${escapeParam(0)}, ${escapeParam(1)}, ${escapeParam(2)})',
      [tag, checksum, DateTime.now().millisecondsSinceEpoch],
    );
  }
}
