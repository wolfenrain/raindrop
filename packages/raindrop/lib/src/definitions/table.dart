import 'package:raindrop/raindrop.dart';

/// {@macro table}
S table<S extends Schema<R>, R>(
  String name,
  S Function(SchemaBuilder<R>) builder, {
  String? dialect,
  void Function(S table)? extra,
}) {
  final table = Table<S, R>._(name, builder, dialect: dialect);
  extra?.call(table.schema);
  return table.schema;
}

/// {@template table}
/// A table holds all the data related to building and querying tables.
///
/// The schema reference instance [S] holds the column-reference fields. Rows
/// are produced by invoking [Schema.fromRow] inside [create].
/// {@endtemplate}
class Table<S extends Schema<R>, R> implements Selectable<R> {
  /// {@macro table}
  Table._(this.name, this.builder, {this.alias, this.dialect})
      : columns = [],
        indexes = [] {
    schema = builder(SchemaBuilder<R>(this));
    Table._schemaToTable[schema as Schema] = this;
  }

  /// The name of the table.
  final String name;

  /// Optional alias used when this table is referenced in a join.
  final String? alias;

  /// The SQL dialect for this table (e.g., 'postgres', 'sqlite').
  final String? dialect;

  /// Returns [alias] or [name].
  String get aliasOrName => alias ?? name;

  /// The schema instance builder for the table.
  final S Function(SchemaBuilder<R>) builder;

  /// The schema reference of this specific table.
  late final S schema;

  /// The columns of the table.
  final List<Column<R, dynamic>> columns;

  /// The indexes defined on this table.
  final List<Index> indexes;

  /// Create a new row [R] instance from a raw column map.
  R create(Map<String, dynamic> data) {
    T read<T extends Object?>(ColumnType<T>? column) {
      if (column == null) {
        throw StateError(
          'Tried to read a null column reference on $name.',
        );
      }
      return column.decode(data[column.name]) as T;
    }

    return schema.fromRow(read);
  }

  /// Create an aliased instance of the table.
  Table<S, R> aliased(String alias) =>
      Table<S, R>._(name, builder, alias: alias, dialect: dialect);

  /// Returns the values of a row [instance] in column order.
  List<dynamic> values(dynamic instance) {
    if (instance is! R) {
      throw StateError('Only $R rows can be converted to values');
    }
    return [...columns.map((c) => c.encode(c.valueOf!(instance)))];
  }

  /// Add a column by [name] and [field] to the table.
  ///
  /// [field] must be a `V? Function(R)` getter, but is accepted as
  /// [Function] so callers don't need to know R statically.
  Column<R, V> addColumn<V extends Object>(
    String name,
    Function field, {
    bool isNullable = false,
    ColumnTransformer<V, Object?>? transformer,
    String? sqlType,
    String? defaultValue,
  }) {
    final column = Column<R, V>(
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

  bool _instanceOfSchema(Schema r) => r is S;

  Column<R, dynamic> operator [](String name) =>
      columns.firstWhere((c) => c.name == name);

  /// Get the table by using a schema reference.
  static Table? get(Schema schema) => _schemaToTable[schema];

  /// Get the table for an actual schema instance.
  static Table<S, R> getFor<S extends Schema<R>, R>(S s) =>
      _schemaToTable.values.firstWhere((e) => e._instanceOfSchema(s))
          as Table<S, R>;

  /// This does not contain aliased schemas.
  static final Map<Schema, Table> _schemaToTable = {};
}
