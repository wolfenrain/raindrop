import 'package:raindrop/raindrop.dart';

/// {@template alias_registry}
/// Registry of aliases used within a query.
/// {@endtemplate}
class AliasRegistry<S extends Schema<S>, V> {
  /// {@macro alias_registry}
  AliasRegistry(Query<S, V> query) {
    var tableCount = 0;
    var columnCount = 0;
    void add(Object item) {
      if (_names.containsKey(item)) return;

      if (item is Table) {
        _objects[_names[item] ??= 't${tableCount++}'] = item;

        return item.columns.forEach(add);
      } else if (item is Column) {
        add(item.table);

        final prefix = item is ColumnTransform ? 'ct' : 'c';
        final columnName = _names[item] ??= item is ColumnAlias
            ? item.alias
            : '${name(item.table)}.$prefix${columnCount++}';
        _objects[columnName] = item;

        return;
      }

      throw UnsupportedError('$item');
    }

    if (query case final Insert<S, V> insert) {
      add(insert.into);
    } else if (query case final Select<S, V> select) {
      final result = SelectableResult<V>(
        [select.selecting, select.from, ...select.joins.map((j) => j.table)],
      );
      result.items.forEach(add);
    } else if (query case final Update<S, V> update) {
      final set = update.set;
      if (set is UpdateableResult<S, V>) {
        for (final item in set.items) {
          if (item is UpdateableColumn) {
            add(item.column);
          } else if (item is UpdatableTable) {
            add(item.table);
          } else {
            throw UnimplementedError('${item.runtimeType}');
          }
        }
      } else if (set is UpdateableColumn<S, V>) {
        add(set.column);
      }
    } else if (query case final Delete<S, V> delete) {
      add(delete.from);
    }
  }

  final Map<Object, String> _names = {};

  final Map<String, Object> _objects = {};

  /// Get the alias name of an object, will throw if the object was not found.
  String name(Object object) => _names[object]!;

  /// Get the object of a name, will throw if the name was not found.
  T object<T>(String name) => _objects[name]! as T;

  /// Get the column info of a column by it's [name].
  Column column(String name) => object(name);

  /// Get the table definition of a table by it's [name].
  Table table(String name) => object(name);
}

extension<V> on SelectableResult<V> {
  Iterable<Selectable<dynamic>> get items sync* {
    for (final select in selected) {
      if (select is SelectableResult) {
        yield* select.items;
      } else {
        yield select;
      }
    }
  }
}
