import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/sqlite_dialect.dart';

/// A capped `UPDATE` or `DELETE`, in whichever form the library can parse.
///
/// SQLite only parses a `LIMIT` hung directly off `UPDATE` or `DELETE` when it
/// was compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`. That option is off in
/// the stock amalgamation and in the binaries `package:sqlite3` ships, so a
/// bare `DELETE ... LIMIT` is a syntax error on the default driver — but it is
/// on in some builds, macOS's system library among them.
///
/// So the form is the dialect's call, not this clause's, and it is decided at
/// render time from [SQLiteDialect.supportsUpdateDeleteLimit]:
///
/// - supported — `[WHERE <filter>] LIMIT <n>`, the cheaper form, one scan.
/// - otherwise — `WHERE <key> IN (SELECT <key> FROM <table> ... LIMIT <n>)`,
///   which every build parses, at the cost of a subquery.
///
/// The key is the table's primary key, compared as a row value when it spans
/// more than one column. A table that declares no primary key falls back to
/// SQLite's implicit `rowid`.
///
/// Either way this clause occupies the statement's own `where` weight and so
/// replaces the core `WHERE` rather than sitting after it. That is why it is
/// handed [filter]: the cap has to apply to the rows the statement was already
/// narrowed to, not to the table at large, so the filter is re-emitted here —
/// inside the subquery in one form, ahead of the `LIMIT` in the other.
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
    final filter = this.filter;
    final where = filter == null
        ? ''
        : WhereClause(filter, singleTable: true).render(context);

    final dialect = context.dialect;
    if (dialect is SQLiteDialect && dialect.supportsUpdateDeleteLimit) {
      return where.isEmpty ? 'LIMIT $limit' : '$where LIMIT $limit';
    }

    final primaryKey = [
      for (final column in table.columns)
        if (column.isPrimaryKey) context.escapeName(column.name),
    ];
    final key = primaryKey.isEmpty ? [context.escapeName('rowid')] : primaryKey;
    final target = key.length > 1 ? '(${key.join(', ')})' : key.single;

    return 'WHERE $target IN (SELECT ${key.join(', ')} '
        'FROM ${TableClause(table).render(context)}'
        '${where.isEmpty ? '' : ' $where'} LIMIT $limit)';
  }
}
