import 'dart:async';

import 'package:raindrop/raindrop.dart';

final fakes = SchemaFake();

class SchemaFake {
  SchemaFake();

  int _counter = 0;

  int primaryKey() => _counter++ * -1;

  String text() => '${_counter++ * -1}';

  int integer() => _counter++ * -1;

  List<T> list<T>(T value) => List.filled(_counter++, value);

  DateTime dateTime() => DateTime.fromMicrosecondsSinceEpoch(_counter++);
}

/// {@macro table}
S table<S extends Schema<S>>(
  String name,
  S Function() builder, {
  String? dialect,
  void Function(S table)? extra,
}) {
  final table = Table<S>._(name, builder, dialect: dialect);
  if (extra case final void Function(S table) extra) {
    runZoned(() => extra(table.schema), zoneValues: {#extra: table});
  }
  return table.schema;
}

/// {@template table}
/// A table holds all the data related to building and querying tables.
///
/// It will automatically build a schema instance that can be used as a table
/// reference for querying while also fully capable of returning true instances
/// of the schema.
/// {@endtemplate}
class Table<S extends Schema<S>?> implements Selectable<S> {
  /// {@macro table}
  Table._(this.name, this.builder, {this.alias, this.dialect})
      : columns = [],
        indexes = [] {
    schema = runZoned(builder, zoneValues: {#table: this});
    Table._schemaToTable[schema as Schema] = this;
  }

  /// The name of the table.
  final String name;

  /// Optional table to use for the table.
  final String? alias;

  /// The SQL dialect for this table (e.g., 'postgres', 'sqlite').
  final String? dialect;

  /// Returns [alias] or [name].
  String get aliasOrName => alias ?? name;

  /// The schema instance builder for the table.
  final S Function() builder;

  /// The schema of this specific table.
  late final S schema;

  /// The columns of the table.
  final List<Column<S, dynamic>> columns;

  /// The indexes defined on this table.
  final List<Index> indexes;

  /// Create a new instance with the [data].
  S create(Map<String, dynamic> data) {
    return runZoned(builder, zoneValues: {#read: data});
  }

  /// Create an aliased instance of the table.
  Table<S> aliased(String alias) =>
      Table<S>._(name, builder, alias: alias, dialect: dialect);

  /// Returns the values of an schema [instance].
  List<dynamic> values(dynamic instance) {
    if (instance is! S) {
      throw StateError('Only $S types can be converted to values');
    }
    return [...columns.map((c) => c.encode(c.valueOf!(instance)))];
  }

  /// Add a column by [name] and [field] to the table.
  ///
  /// The column's value can be transformed for storage using the [transformer]
  /// property.
  Column<S, V> addColumn<V extends Object>(
    String name,
    Field<S, V> field, {
    bool isNullable = false,
    ColumnTransformer<V, Object?>? transformer,
    String? sqlType,
    String? defaultValue,
  }) {
    final column = Column<S, V>(
      this,
      name,
      valueOf: field,
      isNullable: isNullable,
      transformer: transformer,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
    columns.add(column);
    return column;
  }

  /// Adds an index to the table.
  void addIndex(Index index) => indexes.add(index);

  bool _instanceOf(Schema r) => r is S;

  /// Get the table by using a schema reference.
  static Table? get(Schema schema) => _schemaToTable[schema];

  /// Get the table for an actual schema instance.
  ///
  /// This is more expensive then [get] but allows any instance of [S] to be
  /// passed.
  static Table<S> getFor<S extends Schema<S>?>(S s) =>
      _schemaToTable.values.firstWhere((e) => e._instanceOf(s!)) as Table<S>;

  /// This does not contain aliased schemas.
  static final Map<Schema, Table> _schemaToTable = {};
}
