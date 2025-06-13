import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

/// {@template sqlite_dialect}
/// SQL dialect for the SQLite database.
/// {@endtemplate}
class SQLiteDialect extends SqlDialect {
  /// {@macro sqlite_dialect}
  const SQLiteDialect();

  @override
  String translateInsert<S extends Schema<S>, V>(
    Insert<S, V> insert,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    final table = insert.into;
    final buffer = StringBuffer()..write('INSERT INTO ${table.name}');

    final sqlColumns = <String>[];
    final sqlValues = <int, List<String>>{};

    final insertValues = insert.values.map(table.values).toList();
    for (var i = 0; i < table.columns.length; i++) {
      final column = table.columns[i];
      if (column.isPrimaryKey) continue;
      sqlColumns.add(column.name);

      for (var j = 0; j < insertValues.length; j++) {
        final value = insertValues[j][i];

        sqlValues[j] ??= [];
        sqlValues[j]!.add('\$${values.length + 1}');
        values.add(value);
      }
    }

    buffer
      ..write(' (${sqlColumns.join(', ')})')
      ..write(' VALUES ')
      ..write(sqlValues.values.map((e) => '(${e.join(', ')})').join(', '));

    if (insert is SQLiteInsert<S, V>) {
      if (insert.withReturning) {
        buffer.write(
          ' RETURNING ${table.columns.map((e) => e.name).join(', ')}',
        );
      }
    }

    return buffer.toString();
  }

  @override
  String translateSelect<S extends Schema<S>, V>(
    Select<S, V> select,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    String selectColumn(Column column) {
      return [
        if (column is ColumnTransform)
          translateSQL(column.sql, values, registry)
        else
          '${registry.name(column.table)}."${column.name}"',
        'AS "${registry.name(column)}"',
      ].join(' ');
    }

    final columns = select.selecting.getColumns(selectColumn);

    final buffer = StringBuffer()
      ..write('SELECT ${columns.join(', ')}')
      ..write(' FROM ${select.from.name} AS ${registry.name(select.from)}');

    if (select.joins.isNotEmpty) {
      for (final join in select.joins) {
        if (join is InnerJoin) {
          buffer.write(' INNER JOIN ');
        } else if (join is LeftJoin) {
          buffer.write(' LEFT JOIN ');
        } else if (join is RightJoin) {
          buffer.write(' RIGHT JOIN ');
        } else {
          throw UnsupportedError('$join');
        }
        final tableAlias = '${join.table.name} AS ${registry.name(join.table)}';
        buffer.write(
          '$tableAlias ON ${translateFilter(join.on, values, registry)}',
        );
      }
    }

    if (select.where != null) {
      buffer
          .write(' WHERE ${translateFilter(select.where!, values, registry)}');
    }

    if (select.groupBy != null) {
      final groupBy = select.groupBy!;
      buffer.write(' GROUP BY (');
      final columns = groupBy.getColumns((column) {
        return [
          if (column is ColumnTransform)
            translateSQL(column.sql, values, registry)
          else
            '${registry.name(column.table)}."${column.name}"',
        ].join(' ');
      });
      buffer
        ..write(columns.join(', '))
        ..write(')');
    }

    if (select.limit != null) {
      buffer.write(' LIMIT ${select.limit}');
    }

    return buffer.toString();
  }

  @override
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    final table = update.table;
    final buffer = StringBuffer()
      ..write('UPDATE ${table.name} AS ${registry.name(table)} SET');

    final setting = switch (update.set) {
      final UpdateableResult<S, V> result => result.items,
      final UpdateableColumn<S, V> column => [column],
      final UpdateableTable<S> table => [table],
      _ => throw UnsupportedError('${update.set.runtimeType}'),
    };

    for (final set in setting) {
      if (set is UpdateableColumn) {
        buffer.write(' ${set.column.name} = \$${values.length + 1}');

        values.add(set.column.encode(set.value));
        if (set != setting.last) {
          buffer.write(', ');
        }
      } else if (set is UpdateableTable) {
        for (final column in set.table.columns) {
          buffer.write(' ${column.name} = \$${values.length + 1}');
          values.add(column.encode(column.valueOf!(set.value)));
          if (column != set.table.columns.last) {
            buffer.write(', ');
          }
        }
      } else {
        throw UnimplementedError('${set.runtimeType}');
      }
    }

    if (update.where != null) {
      buffer.write(
        ' WHERE ${translateFilter(update.where!, values, registry)}',
      );
    }

    if (update is SQLiteUpdate<S, V>) {
      if (update.withReturning) {
        buffer.write(' RETURNING ');
        for (final set in setting) {
          if (set is UpdateableColumn) {
            buffer
                .write('${set.column.name} as "${registry.name(set.column)}"');
            if (set != setting.last) {
              buffer.write(', ');
            }
          } else if (set is UpdateableTable) {
            // TODO(wolfen): not yet implemented
            throw UnimplementedError('${set.runtimeType}');
          } else {
            throw UnimplementedError('${set.runtimeType}');
          }
        }
      }
    }

    return buffer.toString();
  }

  @override
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    final buffer = StringBuffer()
      ..write(
        'DELETE FROM ${delete.from.name} AS ${registry.name(delete.from)}',
      );

    if (delete.where != null) {
      buffer.write(
        ' WHERE ${translateFilter(delete.where!, values, registry)}',
      );
    }

    if (delete is SQLiteDelete<S, V>) {
      if (delete.withReturning) {
        buffer.write(' RETURNING ');
        for (final column in delete.from.columns) {
          buffer.write(column.name);
          // buffer.write('${column.name} as "${registry.name(column)}"');
          if (column != delete.from.columns.last) {
            buffer.write(', ');
          }
        }
      }
    }

    return buffer.toString();
  }

  @override
  String translateFilter(
    Filter filter,
    List<Object?> values,
    AliasRegistry registry, [
    int level = 0,
  ]) {
    final buffer = StringBuffer();

    if (filter is LogicalFilter) {
      if (level > 0) buffer.write('(');
      buffer
        ..write(translateFilter(filter.left, values, registry, level + 1))
        ..write(filter.or ? ' OR ' : ' AND ')
        ..write(translateFilter(filter.right, values, registry, level + 1));
      if (level > 0) buffer.write(')');
    } else if (filter is SQL) {
      buffer.write(translateSQL(filter, values, registry));
    } else if (filter is Not) {
      buffer.write('NOT (${translateFilter(filter.invert, values, registry)})');
    } else {
      throw UnsupportedError('$runtimeType');
    }

    return buffer.toString();
  }

  String translateSQL(SQL s, List<Object?> values, AliasRegistry registry) {
    final buffer = StringBuffer();
    for (final chunk in s.chunks) {
      if (chunk case final RawSQL chunk) {
        buffer.write(chunk.sql);
      } else if (chunk case final Column column) {
        buffer.write('${registry.name(column.table)}."${column.name}"');
      } else if (chunk case final List<dynamic> values) {
        buffer.write('(');
        for (final value in values) {
          final i = values.length + 1;
          buffer.write('\$$i,');
          values.add(value);
        }
        buffer.write(')');
      } else {
        final i = values.length + 1;
        buffer.write('\$$i');
        values.add(chunk);
      }

      if (chunk != s.chunks.last) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }
}

extension<V> on Selectable<V> {
  List<String> getColumns(String Function(Column) selectColumn) {
    final columns = <String>[];
    void toColumn(Object item) {
      if (item is Table) {
        columns.addAll(item.columns.map(selectColumn));
      } else if (item is Column) {
        columns.add(selectColumn(item));
      } else if (item is SelectableResult) {
        for (final i in item.selected) {
          toColumn(i);
        }
      }
    }

    toColumn(this);
    return columns;
  }
}
