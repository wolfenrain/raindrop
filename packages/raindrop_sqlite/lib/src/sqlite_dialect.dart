import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

/// {@template sqlite_dialect}
/// SQL dialect for the SQLite database.
/// {@endtemplate}
class SQLiteDialect extends SqlDialect {
  /// {@macro sqlite_dialect}
  const SQLiteDialect();

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';

  @override
  String translateInsert<S extends Schema<S>, V>(
    Insert<S, V> insert,
    List<Object?> values,
  ) {
    final table = insert.into;
    final insertValues = insert.values.map(table.values).toList();

    final sqlColumns = <String>[];
    final sqlValues = <int, List<String>>{};
    for (var i = 0; i < table.columns.length; i++) {
      final column = table.columns[i];
      if (column.isPrimaryKey) continue;
      sqlColumns.add(escapeName(column.name));

      for (var j = 0; j < insertValues.length; j++) {
        final value = insertValues[j][i];
        sqlValues[j] ??= [];
        if (value == null) {
          sqlValues[j]!.add('null');
        } else {
          sqlValues[j]!.add(escapeParam(values.length));
          values.add(value);
        }
      }
    }

    final tableSQL = translateTable(table);
    final columnsSQL = sqlColumns.join(', ');
    final valuesSQL =
        sqlValues.values.map((e) => '(${e.join(', ')})').join(', ');
    final returningSQL = switch (insert) {
      final SQLiteInsert<S, V> query when query.withReturning =>
        'RETURNING ${translateSelection(query.into, values)}',
      _ => '',
    };

    return [
      'INSERT INTO',
      tableSQL,
      '($columnsSQL)',
      'VALUES',
      valuesSQL,
      if (returningSQL.isNotEmpty) returningSQL,
    ].join(' ');
  }

  @override
  String translateSelect<S extends Schema<S>, V>(
    Select<S, V> select,
    List<Object?> values,
  ) {
    final singleTable = select.joins.isEmpty;

    final selectionSQL = translateSelection(
      select.selecting,
      values,
      singleTable: singleTable,
    );
    final tableSQL = translateTable(select.from);
    final joinsSQL = translateJoins(select.joins, values);
    final whereSQL = switch (select.where) {
      final Filter filter =>
        'WHERE ${translateFilter(filter, values, singleTable: singleTable)}',
      _ => '',
    };
    // final orderBySQL = switch(select.orderBy) {
    //   _ => '',
    // };
    final groupBySQL = switch (select.groupBy) {
      final Selectable<Object> groupBy =>
        'GROUP BY (${translateSelection(groupBy, values, singleTable: singleTable)})',
      _ => '',
    };
    final limitSQL = switch (select.limit) {
      final int limit => 'LIMIT $limit',
      _ => '',
    };
    final offsetSQL = switch (select.offset) {
      final int offset => 'OFFSET $offset',
      _ => '',
    };

    return [
      'SELECT',
      selectionSQL,
      'FROM',
      tableSQL,
      if (joinsSQL.isNotEmpty) joinsSQL,
      if (whereSQL.isNotEmpty) whereSQL,
      // if (orderBySQL.isNotEmpty) orderBySQL,
      if (groupBySQL.isNotEmpty) groupBySQL,
      if (limitSQL.isNotEmpty) limitSQL,
      if (offsetSQL.isNotEmpty) offsetSQL,
    ].join(' ');
  }

  @override
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
  ) {
    final tableSQL = translateTable(update.table);
    final setSQL = translateUpdateSet(update.set, values);
    final whereSQL = switch (update.where) {
      final Filter filter => 'WHERE ${translateFilter(filter, values)}',
      _ => '',
    };
    final returningSQL = switch (update) {
      final SQLiteUpdate<S, V> query when query.withReturning =>
        'RETURNING ${translateSelection(query.table, values)}',
      _ => '',
    };

    return [
      'UPDATE',
      tableSQL,
      'SET',
      setSQL,
      if (whereSQL.isNotEmpty) whereSQL,
      if (returningSQL.isNotEmpty) returningSQL,
    ].join(' ');
  }

  @override
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
  ) {
    final tableSQL = translateTable(delete.from);
    final whereSQL = switch (delete.where) {
      final Filter filter => 'WHERE ${translateFilter(filter, values)}',
      _ => '',
    };
    final returningSQL = switch (delete) {
      final SQLiteDelete<S, V> query when query.withReturning =>
        'RETURNING ${translateSelection(query.from, values)}',
      _ => '',
    };

    return [
      'DELETE FROM',
      tableSQL,
      if (whereSQL.isNotEmpty) whereSQL,
      if (returningSQL.isNotEmpty) returningSQL,
    ].join(' ');
  }

  @override
  String translateFilter(
    Filter filter,
    List<Object?> values, {
    bool singleTable = false,
    int level = 0,
  }) {
    final buffer = StringBuffer();

    if (filter is LogicalFilter) {
      if (level > 0) buffer.write('(');
      buffer
        ..write(
          translateFilter(
            filter.left,
            values,
            singleTable: singleTable,
            level: level + 1,
          ),
        )
        ..write(filter.or ? ' OR ' : ' AND ')
        ..write(
          translateFilter(
            filter.right,
            values,
            singleTable: singleTable,
            level: level + 1,
          ),
        );
      if (level > 0) buffer.write(')');
    } else if (filter is SQL) {
      buffer.write(translateSQL(filter, values, singleTable: singleTable));
    } else if (filter is Not) {
      buffer.write(
        'NOT (${translateFilter(filter.invert, values, singleTable: singleTable)})',
      );
    } else {
      throw UnsupportedError('$runtimeType');
    }

    return buffer.toString();
  }

  String translateSelection(
    Selectable<dynamic> select,
    List<Object?> values, {
    bool singleTable = true,
  }) {
    final chunks = <String>[];

    if (select case final Schema schema) {
      return translateSelection(
        Table.get(schema)!,
        values,
        singleTable: singleTable,
      );
    }

    if (select case final Table table) {
      for (final column in table.columns) {
        chunks.add(
          translateSelection(column, values, singleTable: singleTable),
        );
        if (column != table.columns.last) {
          chunks.add(', ');
        }
      }
    } else if (select case final Column column) {
      if (column is ColumnTransform) {
        chunks.add(translateSQL(column.sql, values, singleTable: singleTable));
      } else {
        if (column.table.alias case final String alias) {
          chunks.add('${escapeName(alias)}.');
        } else if (!singleTable) {
          chunks.add('${escapeName(column.table.name)}.');
        }
        chunks.add(escapeName(column.name));
      }
    } else if (select case final SelectableResult<dynamic> result) {
      for (final select in result.selected) {
        chunks.add(
          translateSelection(select, values, singleTable: singleTable),
        );
        if (select != result.selected.last) {
          chunks.add(', ');
        }
      }
    }

    return chunks.join();
  }

  String translateTable(Table table) {
    return [
      escapeName(table.name),
      if (table.alias case final String alias) 'AS ${escapeName(alias)}',
    ].join(' ');
  }

  String translateJoins(List<Join> joins, List<Object?> values) {
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
        ..add(translateTable(join.table))
        ..add('ON ${translateFilter(join.on, values)}');
    }

    return chunks.join(' ');
  }

  String translateUpdateSet(Updateable updateSet, List<Object?> values) {
    final chunks = <String>[];
    if (updateSet case UpdateableColumn(:final column, :final value)) {
      chunks.add('${column.name} = ${escapeParam(values.length)}');
      values.add(column.encode(value));
    } else if (updateSet case UpdateableTable(:final table, :final value)) {
      for (final column in table.columns) {
        chunks.add(' ${column.name} = ${escapeParam(values.length)}');
        values.add(column.encode(column.valueOf!(value)));
        if (column != table.columns.last) {
          chunks.add(', ');
        }
      }
    } else if (updateSet case UpdateableResult(:final updating)) {
      for (final update in updating) {
        chunks.add(translateUpdateSet(update, values));
        if (update != updating.last) {
          chunks.add(', ');
        }
      }
    } else {
      throw UnsupportedError('$updateSet');
    }

    return chunks.join(' ');
  }

  String translateSQL(
    SQL sql,
    List<Object?> values, {
    required bool singleTable,
  }) {
    final buffer = StringBuffer();
    for (final chunk in sql.chunks) {
      if (chunk case final RawSQL chunk) {
        buffer.write(chunk.sql);
      } else if (chunk case final Column column) {
        if (singleTable) {
          buffer.write(escapeName(column.name));
        } else {
          buffer.write(
            escapeName('${column.table.aliasOrName}.${column.name}'),
          );
        }
      } else if (chunk case final List<dynamic> values) {
        buffer.write('(');
        for (final value in values) {
          buffer.write(escapeParam(values.length));
          values.add(value);
        }
        buffer.write(')');
      } else {
        buffer.write(escapeParam(values.length));
        values.add(chunk);
      }

      if (chunk != sql.chunks.last) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }
}
