import 'package:raindrop/raindrop.dart';

/// {@template base_sql_dialect}
/// Base SQL dialect with common implementation for standard SQL databases.
/// {@endtemplate}
abstract class BaseSqlDialect extends SqlDialect {
  /// {@macro base_sql_dialect}
  const BaseSqlDialect();

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
      if (column.isPrimaryKey) {
        final hasValue = insertValues.any((values) => values[i] != null);
        if (!hasValue) continue;
      }
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
      final ReturningQuery query when query.withReturning =>
        'RETURNING ${translateSelection(insert.into, values)}',
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
      final Selectable<Object> groupBy => 'GROUP BY (${translateSelection(
          groupBy,
          values,
          singleTable: singleTable,
        )})',
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
      final Filter filter =>
        'WHERE ${translateFilter(filter, values, singleTable: true)}',
      _ => '',
    };
    final returningSQL = switch (update) {
      final ReturningQuery query when query.withReturning =>
        'RETURNING ${translateUpdateable(update.set, values)}',
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
      final ReturningQuery query when query.withReturning =>
        'RETURNING ${translateSelection(delete.from, values)}',
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
      final invertedFilter = translateFilter(
        filter.invert,
        values,
        singleTable: singleTable,
      );
      buffer.write('NOT ($invertedFilter)');
    } else {
      throw UnsupportedError('$runtimeType');
    }

    return buffer.toString();
  }

  /// Translate a [select] into a SQL selection.
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
      for (var i = 0; i < table.columns.length; i++) {
        chunks.add(
          translateSelection(
            table.columns[i],
            values,
            singleTable: singleTable,
          ),
        );
        if (i != table.columns.length - 1) {
          chunks.add(', ');
        }
      }
    } else if (select case final Column column) {
      if (column is ColumnTransform) {
        chunks.add(translateSQL(column.sql, values, singleTable: singleTable));
      } else if (singleTable) {
        chunks.add(escapeName(column.name));
      } else {
        // Use table prefix and alias to avoid column name collisions in joins
        final prefix = column.table.alias ?? column.table.name;
        final colName = escapeName(column.name);
        final alias = escapeName('${prefix}__${column.name}');
        chunks.add('${escapeName(prefix)}.$colName AS $alias');
      }
    } else if (select case final SelectableResult<dynamic> result) {
      for (var i = 0; i < result.selected.length; i++) {
        chunks.add(
          translateSelection(
            result.selected[i],
            values,
            singleTable: singleTable,
          ),
        );
        if (i != result.selected.length - 1) {
          chunks.add(', ');
        }
      }
    }

    return chunks.join();
  }

  /// Translate an [update] into a SQL selection for RETURNING clause.
  String translateUpdateable(
    Updateable<dynamic> update,
    List<Object?> values, {
    bool singleTable = true,
  }) {
    final chunks = <String>[];

    if (update case final UpdateableTable update) {
      final table = update.table;
      for (var i = 0; i < table.columns.length; i++) {
        chunks.add(
          translateSelection(
            table.columns[i],
            values,
            singleTable: singleTable,
          ),
        );
        if (i != table.columns.length - 1) {
          chunks.add(', ');
        }
      }
    } else if (update case final UpdateableColumn<dynamic> update) {
      final column = update.column;
      if (column case final ColumnTransform column) {
        chunks.add(translateSQL(column.sql, values, singleTable: singleTable));
      } else {
        if (column.table.alias case final String alias) {
          chunks.add('${escapeName(alias)}.');
        } else if (!singleTable) {
          chunks.add('${escapeName(column.table.name)}.');
        }
        chunks.add(escapeName(column.name));
      }
    } else if (update case final UpdateableResult<dynamic> result) {
      for (var i = 0; i < result.updating.length; i++) {
        chunks.add(
          translateUpdateable(
            result.updating[i],
            values,
            singleTable: singleTable,
          ),
        );
        if (i != result.updating.length - 1) {
          chunks.add(', ');
        }
      }
    }

    return chunks.join();
  }

  /// Translate a [table] into a SQL table reference.
  String translateTable(Table table) {
    return [
      escapeName(table.name),
      if (table.alias case final String alias) 'AS ${escapeName(alias)}',
    ].join(' ');
  }

  /// Translate [joins] into a SQL JOIN clause.
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

  /// Translate an [updateSet] into a SQL SET clause.
  String translateUpdateSet(
    Updateable<dynamic> updateSet,
    List<Object?> values,
  ) {
    final chunks = <String>[];
    if (updateSet case UpdateableColumn(:final column, :final value)) {
      chunks.add('"${column.name}" = ${escapeParam(values.length)}');
      values.add(column.encode(value));
    } else if (updateSet case UpdateableTable(:final table, :final value)) {
      final buffer = StringBuffer();
      for (var i = 0; i < table.columns.length; i++) {
        final column = table.columns[i];
        final columnValue = column.readValueOf(value);
        if (column.isPrimaryKey && columnValue == null) continue;

        buffer.write('"${column.name}" = ${escapeParam(values.length)}');
        values.add(column.encode(columnValue));
        if (i != table.columns.length - 1) {
          buffer.write(', ');
        }
      }
      chunks.add(buffer.toString());
    } else if (updateSet case UpdateableResult(:final updating)) {
      final buffer = StringBuffer();
      for (var i = 0; i < updating.length; i++) {
        buffer.write(translateUpdateSet(updating[i], values));
        if (i != updating.length - 1) {
          buffer.write(', ');
        }
      }
      chunks.add(buffer.toString());
    } else {
      throw UnsupportedError('$updateSet');
    }

    return chunks.join(' ');
  }

  /// Translate a [sql] into a SQL string.
  String translateSQL(
    SQL sql,
    List<Object?> values, {
    required bool singleTable,
  }) {
    final buffer = StringBuffer();
    for (var i = 0; i < sql.chunks.length; i++) {
      final chunk = sql.chunks[i];
      if (chunk case final RawSQL chunk) {
        buffer.write(chunk.sql);
      } else if (chunk case final Column column) {
        if (column.table.alias case final String alias) {
          buffer.write('${escapeName(alias)}.');
        } else if (!singleTable) {
          buffer.write('${escapeName(column.table.name)}.');
        }
        buffer.write(escapeName(column.name));
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

      if (i != sql.chunks.length - 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }
}
