import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/src/sqlite_dialect.dart';

/// A capped `UPDATE` or `DELETE`, in whichever form the library can parse.
///
/// SQLite only parses `UPDATE/DELETE ... LIMIT` when compiled with
/// `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`, so the form is decided at render time
/// from [SQLiteDialect.supportsUpdateDeleteLimit]:
///
/// - supported, `[WHERE <filter>] LIMIT <n>`.
/// - otherwise, `WHERE <key> IN (SELECT <key> FROM <table> ... LIMIT <n>)`,
///   keyed by the primary key, or by `rowid` when none is declared.
///
/// Occupies the statement's own `where` weight, replacing the core `WHERE`,
/// so it re-emits [filter] itself.
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
    final where = switch (filter) {
      final filter? => WhereClause(filter, singleTable: true).render(context),
      _ => '',
    };
    final cap = LimitClause(limit).render(context);

    final dialect = context.dialect;
    if (dialect case final SQLiteDialect d when d.supportsUpdateDeleteLimit) {
      // The cap travels on [LimitedWriteTailClause] instead: SQLite parses
      // `LIMIT` only after `RETURNING`, and this clause sits at the
      // statement's `where` weight, ahead of it.
      return where;
    }

    final primaryKeys = [
      for (final column in table.columns)
        if (column.isPrimaryKey) context.escapeName(column.name),
    ];

    final key = primaryKeys.isEmpty ? ['rowid'] : primaryKeys;
    final target = key.length > 1 ? '(${key.join(', ')})' : key.single;

    return 'WHERE $target IN (SELECT ${key.join(', ')} '
        'FROM ${TableClause(table).render(context)}'
        '${where.isEmpty ? '' : ' $where'} $cap)';
  }
}

/// The `LIMIT <n>` of a bare capped write, emitted after any `RETURNING`.
///
/// Renders nothing when [LimitedWriteClause] took the key-subquery form,
/// which already carries its own cap.
class LimitedWriteTailClause extends Clause {
  /// Creates the trailing cap of a write limited to [limit] rows.
  const LimitedWriteTailClause(this.limit);

  /// The most rows the write may affect.
  final int limit;

  @override
  String render(RenderContext context) {
    final dialect = context.dialect;
    if (dialect case final SQLiteDialect d when d.supportsUpdateDeleteLimit) {
      return LimitClause(limit).render(context);
    }
    return '';
  }
}
