import 'dart:async';

import 'package:raindrop/raindrop.dart';

class SchemaFake {
  const SchemaFake();

  int primaryKey() => -1;

  String text() => '-1';

  int integer() => -1;
}

const fakes = SchemaFake();

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
    return [...columns.map((c) => c.valueOf!(instance))];
  }

  Column<S, T> addColumn<T extends Object?>(
    String name,
    T Function(S) valueOf, {
    bool isNullable = false,
    bool isPrimaryKey = false,
  }) {
    final column = Column<S, T>(
      this,
      name,
      valueOf: valueOf,
      isNullable: isNullable,
      isPrimaryKey: isPrimaryKey,
    );
    columns.add(column);
    return column;
  }

  static Table<R>? getForSchema<R extends Schema<R>>() {
    return _schemaToTable[R] as Table<R>?;
  }

  static final Map<Type, Table> _schemaToTable = {};
}
