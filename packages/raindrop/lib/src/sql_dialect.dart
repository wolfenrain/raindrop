import 'package:raindrop/dialect.dart';

/// The executing migration.
typedef MigrationExecute = Future<DatabaseResult> Function(
  String sql, [
  List<Object?> values,
]);

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

  /// Identifies the SQL flavor this dialect speaks.
  String get name;

  /// Translate [query] into a SQL statement with its ordered bind values.
  (String, List<Object?>) translate(Query<dynamic> query) {
    return Raindrop.tracer.trace('$runtimeType.translate', (span) {
      final context = RenderContext(this);
      final sql = QueryClause(query).render(context);
      span?.attributes.addAll({'sql': sql, 'values': context.values});
      return (sql, context.values);
    });
  }

  /// Splits a multi-statement script on statement-terminating semicolons.
  ///
  /// A bare `sql.split(';')` is fine for generated DDL and wrong for anything
  /// hand-written: `VALUES ('a; b')` would be torn into two broken
  /// statements, silently. Comment-only fragments are dropped: they are not
  /// statements, and a hand-written migration is mostly comments.
  List<String> splitStatements(String sql) {
    final statements = <String>[];
    final buffer = StringBuffer();

    var index = 0;
    while (index < sql.length) {
      final char = sql[index];

      if (char == '-' && _peek(sql, index + 1) == '-') {
        while (index < sql.length && sql[index] != '\n') {
          buffer.write(sql[index++]);
        }
        continue;
      }

      if (char == '/' && _peek(sql, index + 1) == '*') {
        buffer.write('/*');
        index += 2;
        while (index < sql.length &&
            !(sql[index] == '*' && _peek(sql, index + 1) == '/')) {
          buffer.write(sql[index++]);
        }
        if (index < sql.length) {
          buffer.write('*/');
          index += 2;
        }
        continue;
      }

      // A dialect-specific quote runs until its delimiter recurs verbatim.
      final delimiterLength = matchQuoteDelimiter(sql, index);
      if (delimiterLength > 0) {
        final delimiter = sql.substring(index, index + delimiterLength);
        buffer.write(delimiter);
        index += delimiterLength;
        final end = sql.indexOf(delimiter, index);
        if (end == -1) {
          buffer.write(sql.substring(index));
          index = sql.length;
        } else {
          buffer.write(sql.substring(index, end + delimiterLength));
          index = end + delimiterLength;
        }
        continue;
      }

      // Single quotes are string literals so double quotes and backticks are
      // quoted identifiers. All three can contain a semicolon, and all three
      // escape their delimiter by doubling it.
      if (char == "'" || char == '"' || char == '`') {
        buffer.write(sql[index++]);
        while (index < sql.length) {
          if (sql[index] == char) {
            if (_peek(sql, index + 1) == char) {
              buffer
                ..write(char)
                ..write(char);
              index += 2;
              continue;
            }
            buffer.write(sql[index++]);
            break;
          }
          buffer.write(sql[index++]);
        }
        continue;
      }

      if (char == ';') {
        statements.add(buffer.toString());
        buffer.clear();
        index++;
        continue;
      }

      buffer.write(sql[index++]);
    }
    statements.add(buffer.toString());

    return [
      for (final statement in statements)
        if (_isExecutable(statement)) statement.trim(),
    ];
  }

  /// The length of a dialect-specific quote delimiter opening at [index] of
  /// [sql], or 0 when there is none.
  ///
  /// [splitStatements] consumes from the delimiter to its next verbatim
  /// recurrence without interpreting the contents.
  int matchQuoteDelimiter(String sql, int index) => 0;

  /// Whether anything survives once comments and whitespace are discounted.
  bool _isExecutable(String statement) {
    var index = 0;
    while (index < statement.length) {
      final char = statement[index];

      if (char == '-' && _peek(statement, index + 1) == '-') {
        while (index < statement.length && statement[index] != '\n') {
          index++;
        }
        continue;
      }

      if (char == '/' && _peek(statement, index + 1) == '*') {
        index += 2;
        while (index < statement.length &&
            !(statement[index] == '*' && _peek(statement, index + 1) == '/')) {
          index++;
        }
        index += 2;
        continue;
      }

      if (char.trim().isNotEmpty) return true;
      index++;
    }
    return false;
  }

  String? _peek(String sql, int index) =>
      index < sql.length ? sql[index] : null;

  /// Escape the [name] of a table or column for SQL consumption.
  String escapeName(String name);

  /// The placeholder for the bind parameter at zero-based [number].
  String escapeParam(int number);

  /// Render [value] as a SQL literal, for the places that cannot bind.
  String escapeLiteral(Object? value);

  /// Ensures that the migration tracking storage exists.
  Future<void> ensureMigrationStorage(MigrationExecute execute) async {
    final table = escapeName('_raindrop_migrations');
    final id = escapeName('id');
    final tag = escapeName('tag');
    final checksum = escapeName('checksum');
    final appliedAt = escapeName('applied_at');
    await execute(
      '''
CREATE TABLE IF NOT EXISTS $table ($id INTEGER PRIMARY KEY, $tag TEXT NOT NULL UNIQUE, $checksum TEXT NOT NULL, $appliedAt INTEGER NOT NULL)''',
    );
  }

  /// Loads all previously applied migrations, ordered by application order.
  Future<List<({String tag, String checksum})>> loadAppliedMigrations(
    MigrationExecute execute,
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
      '''
INSERT INTO $table ($tagCol, $checksumCol, $appliedAt) VALUES (${escapeParam(0)}, ${escapeParam(1)}, ${escapeParam(2)})''',
      [tag, checksum, DateTime.now().millisecondsSinceEpoch],
    );
  }
}
