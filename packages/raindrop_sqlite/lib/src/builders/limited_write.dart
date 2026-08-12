import 'package:raindrop/dialect.dart';

/// `WHERE <key> IN (SELECT <key> FROM <table> [WHERE <filter>] LIMIT <n>)`.
///
/// SQLite only parses a `LIMIT` hung directly off `UPDATE` or `DELETE` when it
/// was compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`. That option is off in
/// the stock amalgamation and in the binaries `package:sqlite3` ships, so a
/// bare `DELETE ... LIMIT` is a syntax error on the default driver. Naming the
/// rows to touch in a subquery says the same thing and parses on every build.
///
/// The key is the table's primary key, compared as a row value when it spans
/// more than one column. A table that declares no primary key falls back to
/// SQLite's implicit `rowid`.
///
/// This replaces the statement's `WHERE` rather than sitting after it, so
/// [filter] is restated inside the subquery: the cap has to apply to the rows
/// the statement was already narrowed to, not to the table at large.
class LimitedWriteClause extends Clause {
  /// Creates a clause capping a write to [limit] rows of [table] matching
  /// [filter].
  const LimitedWriteClause({
    required this.table,
    required this.limit,
    this.filter,
  });

  /// The table being written to.
  final Table<Schema<dynamic>, dynamic> table;

  /// The most rows the write may affect.
  final int limit;

  /// What the statement filters rows down to, if anything.
  final Filter? filter;

  @override
  String render(RenderContext context) {
    final primaryKey = [
      for (final column in table.columns)
        if (column.isPrimaryKey) context.escapeName(column.name),
    ];
    final key = primaryKey.isEmpty ? [context.escapeName('rowid')] : primaryKey;
    final target = key.length > 1 ? '(${key.join(', ')})' : key.single;

    final filter = this.filter;
    final where = filter == null
        ? ''
        : ' ${WhereClause(filter, singleTable: true).render(context)}';

    return 'WHERE $target IN (SELECT ${key.join(', ')} '
        'FROM ${TableClause(table).render(context)}$where LIMIT $limit)';
  }
}
