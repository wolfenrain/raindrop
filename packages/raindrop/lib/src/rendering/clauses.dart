import 'package:raindrop/dialect.dart';

/// Renders a [SQL] fragment (its chunk list: raw SQL, columns, value lists,
/// and literal bind values).
class ExpressionClause extends Clause {
  /// Creates an expression clause for [sql].
  const ExpressionClause(this.sql, {this.singleTable = false});

  /// The SQL fragment to render.
  final SQL sql;

  /// When false, column references are table-qualified.
  final bool singleTable;

  @override
  String render(RenderContext context) {
    final buffer = StringBuffer();
    for (var i = 0; i < sql.chunks.length; i++) {
      final chunk = sql.chunks[i];
      if (chunk case [final Subquery<dynamic> only]) {
        buffer.write(_chunk(context, only));
      } else if (chunk case final List<dynamic> list) {
        buffer.write('(');
        for (var j = 0; j < list.length; j++) {
          if (j > 0) buffer.write(', ');
          buffer.write(_chunk(context, list[j]));
        }
        buffer.write(')');
      } else {
        buffer.write(_chunk(context, chunk));
      }

      if (i != sql.chunks.length - 1 &&
          !_endsWithOpenParen(chunk) &&
          !_startsWithCloseParen(sql.chunks[i + 1]) &&
          !_isComma(sql.chunks[i + 1])) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Renders one chunk.
  ///
  /// Anything that is already SQL, is already written out:
  /// - raw text
  /// - a column reference
  /// - a nested expression
  ///
  /// Only a value falls through to a bind, which is what keeps
  /// [RenderContext.values] aligned with the placeholders.
  ///
  /// Nested expressions render recursively rather than having their chunks
  /// spliced in: the spacing rules below key off neighbouring [RawSQL], and a
  /// rendered string is opaque to them.
  String _chunk(RenderContext context, Object? chunk) {
    if (chunk case final RawSQL raw) return raw.sql;

    if (chunk case final Column column) {
      final buffer = StringBuffer();
      if (column.table.alias case final String alias) {
        buffer.write('${context.escapeName(alias)}.');
      } else if (!singleTable) {
        buffer.write('${context.escapeName(column.table.name)}.');
      }
      return (buffer..write(context.escapeName(column.name))).toString();
    }

    if (chunk case final Expression<dynamic> expression) {
      return ExpressionClause(expression.build(), singleTable: singleTable)
          .render(context);
    }

    if (chunk case final SQL nested) {
      return ExpressionClause(nested, singleTable: singleTable).render(context);
    }

    if (chunk case final Clause clause) {
      return clause.render(context);
    }

    return context.param(chunk);
  }

  static bool _endsWithOpenParen(Object? chunk) =>
      chunk is RawSQL && chunk.sql.endsWith('(');

  static bool _startsWithCloseParen(Object? chunk) =>
      chunk is RawSQL && chunk.sql.startsWith(')');

  static bool _isComma(Object? chunk) => chunk is RawSQL && chunk.sql == ',';
}

/// Renders a [Filter] tree: `AND`/`OR` logical groups, `NOT`, and leaf [SQL].
class FilterClause extends Clause {
  /// Creates a filter clause.
  const FilterClause(this.filter, {this.singleTable = false, this.level = 0});

  /// The filter to render.
  final Filter filter;

  /// When false, column references are table-qualified.
  final bool singleTable;

  /// Nesting depth, used to parenthesize nested logical groups.
  final int level;

  @override
  String render(RenderContext context) {
    final buffer = StringBuffer();
    final f = filter;
    if (f is LogicalFilter) {
      if (level > 0) buffer.write('(');
      buffer
        ..write(
          FilterClause(f.left, singleTable: singleTable, level: level + 1)
              .render(context),
        )
        ..write(f.or ? ' OR ' : ' AND ')
        ..write(
          FilterClause(f.right, singleTable: singleTable, level: level + 1)
              .render(context),
        );
      if (level > 0) buffer.write(')');
    } else if (f is SQL) {
      buffer
          .write(ExpressionClause(f, singleTable: singleTable).render(context));
    } else if (f is Not) {
      final inverted =
          FilterClause(f.invert, singleTable: singleTable).render(context);
      buffer.write('NOT ($inverted)');
    } else if (f case final Expression<dynamic> expression) {
      buffer.write(
        ExpressionClause(SQL([expression]), singleTable: singleTable)
            .render(context),
      );
    } else {
      throw UnsupportedError('${f.runtimeType}');
    }
    return buffer.toString();
  }
}

/// Renders a `SELECT` selection: a whole table's columns, a single column
/// (aliased when joins are present), an [Expression], or a tuple of these.
class SelectionClause extends Clause {
  /// Creates a selection clause.
  const SelectionClause(this.select, {this.singleTable = true});

  /// What is being selected.
  final Selectable<dynamic> select;

  /// When false, columns are qualified + aliased to avoid join collisions.
  final bool singleTable;

  @override
  String render(RenderContext context) {
    final select = this.select;
    final chunks = <String>[];

    if (select case final Schema schema) {
      return SelectionClause(Table.get(schema)!, singleTable: singleTable)
          .render(context);
    }

    if (select case final Table table) {
      for (var i = 0; i < table.columns.length; i++) {
        chunks.add(
          SelectionClause(table.columns[i], singleTable: singleTable)
              .render(context),
        );
        if (i != table.columns.length - 1) chunks.add(', ');
      }
    } else if (select case final Column column) {
      final explicit = switch (column) {
        final ColumnAlias<dynamic, dynamic> aliased => aliased.alias,
        _ => null,
      };
      if (singleTable) {
        final name = context.escapeName(column.name);
        chunks.add(
          explicit == null ? name : '$name AS ${context.escapeName(explicit)}',
        );
      } else {
        final prefix = column.table.alias ?? column.table.name;
        final colName = context.escapeName(column.name);
        final alias =
            context.escapeName(explicit ?? '${prefix}__${column.name}');
        chunks.add('${context.escapeName(prefix)}.$colName AS $alias');
      }
    } else if (select case final AliasedExpression<dynamic> aliased) {
      final rendered = ExpressionClause(
        aliased.build(),
        singleTable: singleTable,
      ).render(context);
      chunks.add('$rendered AS ${context.escapeName(aliased.alias)}');
    } else if (select case final Expression<dynamic> expr) {
      chunks.add(ExpressionClause(expr.build(), singleTable: singleTable)
          .render(context));
    } else if (select case final SelectableResult<dynamic> result) {
      for (var i = 0; i < result.selected.length; i++) {
        chunks.add(
          SelectionClause(result.selected[i], singleTable: singleTable)
              .render(context),
        );
        if (i != result.selected.length - 1) chunks.add(', ');
      }
    }

    return chunks.join();
  }
}

/// Renders a table reference (`"name"` or `"name" AS "alias"`).
class TableClause extends Clause {
  /// Creates a table-reference clause.
  const TableClause(this.table);

  /// The table to reference.
  final Table table;

  @override
  String render(RenderContext context) {
    if (table.derivedFrom case final Query<dynamic> query) {
      final inner = QueryClause(query).render(context);
      return '($inner) AS ${context.escapeName(table.aliasOrName)}';
    }
    return [
      context.escapeName(table.name),
      if (table.alias case final String alias)
        'AS ${context.escapeName(alias)}',
    ].join(' ');
  }
}

/// `HAVING <filter>`, the group-level counterpart to `WHERE`.
class HavingClause extends Clause {
  /// Creates a having clause.
  const HavingClause(this.filter, {this.singleTable = false});

  /// The filter.
  final Filter filter;

  /// When false, column references are table-qualified.
  final bool singleTable;

  @override
  String render(RenderContext context) =>
      'HAVING ${FilterClause(filter, singleTable: singleTable).render(context)}';
}

/// Renders a list of `JOIN` clauses.
class JoinsClause extends Clause {
  /// Creates a joins clause.
  const JoinsClause(this.joins);

  /// The joins to render.
  final List<Join> joins;

  @override
  String render(RenderContext context) {
    if (joins.isEmpty) return '';
    final chunks = <String>[];
    for (final join in joins) {
      if (join is InnerJoin) {
        chunks.add('INNER JOIN');
      } else if (join is LeftJoin) {
        chunks.add('LEFT JOIN');
      } else if (join is RightJoin) {
        chunks.add('RIGHT JOIN');
      } else {
        throw UnsupportedError('$join');
      }
      chunks
        ..add(TableClause(join.table).render(context))
        ..add('ON ${FilterClause(join.on).render(context)}');
    }
    return chunks.join(' ');
  }
}

/// Renders the assignment list of an `UPDATE ... SET ...`.
class UpdateSetClause extends Clause {
  /// Creates an update-set clause.
  const UpdateSetClause(this.updateSet);

  /// The assignments to render.
  final Updateable<dynamic> updateSet;

  @override
  String render(RenderContext context) {
    final updateSet = this.updateSet;
    final chunks = <String>[];
    if (updateSet case UpdateableColumn(:final column, :final value)) {
      chunks.add(
        '${context.escapeName(column.name)} = '
        '${ExpressionClause(SQL([value]), singleTable: true).render(context)}',
      );
    } else if (updateSet case UpdateableTable(:final table, :final value)) {
      final buffer = StringBuffer();
      for (var i = 0; i < table.columns.length; i++) {
        final column = table.columns[i];
        final columnValue = column.readValueOf(value);
        if (column.isPrimaryKey && columnValue == null) continue;
        buffer.write(
          '${context.escapeName(column.name)} = ${context.param(column.encode(columnValue))}',
        );
        if (i != table.columns.length - 1) buffer.write(', ');
      }
      chunks.add(buffer.toString());
    } else if (updateSet case UpdateableResult(:final updating)) {
      final buffer = StringBuffer();
      for (var i = 0; i < updating.length; i++) {
        buffer.write(UpdateSetClause(updating[i]).render(context));
        if (i != updating.length - 1) buffer.write(', ');
      }
      chunks.add(buffer.toString());
    } else {
      throw UnsupportedError('$updateSet');
    }
    return chunks.join(' ');
  }
}

/// `WHERE <filter>`.
class WhereClause extends Clause {
  /// Creates a where clause.
  const WhereClause(this.filter, {this.singleTable = false});

  /// The filter.
  final Filter filter;

  /// When false, columns are table-qualified.
  final bool singleTable;

  @override
  String render(RenderContext context) =>
      'WHERE ${FilterClause(filter, singleTable: singleTable).render(context)}';
}

/// `GROUP BY <selection>`.
class GroupByClause extends Clause {
  /// Creates a group-by clause.
  const GroupByClause(this.groupBy, {this.singleTable = true});

  /// What to group by.
  final Selectable<dynamic> groupBy;

  /// When false, columns are table-qualified.
  final bool singleTable;

  @override
  String render(RenderContext context) {
    final sql = switch (groupBy) {
      final Expression<dynamic> expr => expr.build(),
      final Column column => SQL([column]),
      _ => throw UnsupportedError(
          'Unsupported GROUP BY term: ${groupBy.runtimeType}',
        ),
    };
    return '''GROUP BY ${ExpressionClause(sql, singleTable: singleTable).render(context)}''';
  }
}

/// `ORDER BY <term> ASC|DESC, ...`.
class OrderByClause extends Clause {
  /// Creates an order-by clause.
  const OrderByClause(this.terms, {this.singleTable = true});

  /// The ordering terms.
  final List<OrderBy> terms;

  /// When false, columns are table-qualified.
  final bool singleTable;

  @override
  String render(RenderContext context) {
    if (terms.isEmpty) return '';
    final rendered = terms.map((term) {
      final sql = switch (term.term) {
        final Expression<dynamic> expr => expr.build(),
        final Column column => SQL([column]),
        _ => throw UnsupportedError(
            'Unsupported ORDER BY term: ${term.term.runtimeType}',
          ),
      };
      final direction = term.descending ? 'DESC' : 'ASC';
      return '${ExpressionClause(sql, singleTable: singleTable).render(context)} '
          '$direction';
    });
    return 'ORDER BY ${rendered.join(', ')}';
  }
}

/// `LIMIT <n>`.
class LimitClause extends Clause {
  /// Creates a limit clause.
  const LimitClause(this.limit);

  /// The row limit.
  final int limit;

  @override
  String render(RenderContext context) => 'LIMIT $limit';
}

/// `OFFSET <n>`.
class OffsetClause extends Clause {
  /// Creates an offset clause.
  const OffsetClause(this.offset);

  /// The row offset.
  final int offset;

  @override
  String render(RenderContext context) => 'OFFSET $offset';
}

/// `RETURNING <selection>` for inserts/deletes (whole-row by table).
class ReturningClause extends Clause {
  /// Creates a returning clause for a [selectable] (typically the table).
  const ReturningClause(this.selectable);

  /// What to return.
  final Selectable<dynamic> selectable;

  @override
  String render(RenderContext context) =>
      'RETURNING ${SelectionClause(selectable).render(context)}';
}

/// The body of an `INSERT`: `INTO <table> (<cols>) VALUES (<...>), ...`.
///
/// The leading verb (`INSERT`) is a separate [Keyword] clause, so a dialect can
/// slot a modifier like `OR IGNORE` between the verb and this body.
class InsertBodyClause extends Clause {
  /// Creates an insert-body clause.
  const InsertBodyClause(this.into, this.rows);

  /// The table being inserted into.
  final Table into;

  /// The row instances to insert.
  final List<dynamic> rows;

  @override
  String render(RenderContext context) {
    final encoded = rows.map(into.values).toList();

    final sqlColumns = <String>[];
    final included = <int>[];
    for (var i = 0; i < into.columns.length; i++) {
      final column = into.columns[i];
      if (column.isPrimaryKey || column.defaultValue != null) {
        final hasValue = encoded.any((vals) => vals[i] != null);
        if (!hasValue) continue;
      }
      sqlColumns.add(context.escapeName(column.name));
      included.add(i);
    }

    final tuples = <String>[];
    for (final row in encoded) {
      final placeholders = [for (final i in included) context.param(row[i])];
      tuples.add('(${placeholders.join(', ')})');
    }

    return 'INTO ${TableClause(into).render(context)} '
        '(${sqlColumns.join(', ')}) VALUES ${tuples.join(', ')}';
  }
}

/// Renders a whole [Query], every clause in weight order, into the context
/// it is given.
///
/// The context matters more than it looks. Bind placeholders are numbered from
/// how many values the context has already collected, so a nested query has to
/// share the outer one's context or it restarts at the first placeholder and
/// silently renumbers everything after it. Rendering through this clause is
/// what keeps a subquery's binds interleaved with its parent's.
class QueryClause extends Clause {
  /// Creates a clause that renders [query].
  const QueryClause(this.query);

  /// The query to render.
  final Query<dynamic> query;

  @override
  String render(RenderContext context) {
    final weights = query.clauses.keys.toList()..sort();
    final parts = <String>[];
    for (final weight in weights) {
      final rendered = query.clauses[weight]!.render(context);
      if (rendered.isNotEmpty) parts.add(rendered);
    }
    return parts.join(' ');
  }
}

/// `FROM <table>`.
class FromClause extends Clause {
  /// Creates a from clause.
  const FromClause(this.table);

  /// The table being selected from.
  final Table table;

  @override
  String render(RenderContext context) =>
      'FROM ${TableClause(table).render(context)}';
}

/// `SET <assignments>` for an `UPDATE`.
class SetClause extends Clause {
  /// Creates a set clause.
  const SetClause(this.assignments);

  /// The assignments to apply.
  final Updateable<dynamic> assignments;

  @override
  String render(RenderContext context) =>
      'SET ${UpdateSetClause(assignments).render(context)}';
}

/// `DELETE FROM <table>`.
class DeleteFromClause extends Clause {
  /// Creates a delete-from clause.
  const DeleteFromClause(this.from);

  /// The table to delete from.
  final Table from;

  @override
  String render(RenderContext context) =>
      'DELETE FROM ${TableClause(from).render(context)}';
}
