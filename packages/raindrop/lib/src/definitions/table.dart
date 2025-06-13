import 'dart:async';

import 'package:raindrop/raindrop.dart';

class SchemaFake {
  SchemaFake();

  int _counter = 0;

  int primaryKey() => _counter++ * -1;

  String text() => '${_counter++ * -1}';

  int integer() => _counter++ * -1;

  DateTime dateTime() => DateTime.fromMicrosecondsSinceEpoch(_counter++);
}

final fakes = SchemaFake();

class SchemaBuilder<S extends Schema<S>> {
  const SchemaBuilder();
}

S table<S extends Schema<S>>(String name, S Function() builder) {
  final table = Table._(name, builder);
  final schema = runZoned(table.builder, zoneValues: {#table: table});
  Table._schemaToTable[S] = table;
  return schema;
}

class Table<S extends Schema<S>> implements Selectable<S> {
  Table._(this.name, this.builder) : columns = [];

  final String name;

  final S Function() builder;

  final List<Column<S, dynamic>> columns;

  S create(Map<String, dynamic> data) {
    return runZoned(builder, zoneValues: {#read: data});
  }

  List<dynamic> values(dynamic instance) {
    if (instance is! S) {
      throw StateError('Only $S types can be converted to values');
    }
    return [
      ...columns.map((c) => c.encode(c.valueOf!(instance))),
    ];
  }

  Column<S, V> addColumn<V extends Object>(
    String name,
    Field<S, V> field, {
    bool isNullable = false,
    ColumnTransformer<V, Object?>? transformer,
  }) {
    final column = Column<S, V>(
      this,
      name,
      valueOf: field,
      isNullable: isNullable,
      transformer: transformer,
    );
    columns.add(column);
    return column;
  }

  static Table<R>? getForSchema<R extends Schema<R>>() {
    return _schemaToTable[R] as Table<R>?;
  }

  static final Map<Type, Table> _schemaToTable = {};
}
