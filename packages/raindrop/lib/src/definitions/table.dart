import 'package:meta/meta.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/rendering/clause.dart';

/// {@macro table}
S table<S extends Schema<R>, R>(
  String name,
  S Function(SchemaBuilder<R>) builder, {
  SqlDialect? dialect,
  void Function(S table)? extra,
}) {
  final table = Table<S, R>._(name, builder, dialect: dialect);
  extra?.call(table.schema);
  return table.schema;
}

/// A table whose rows come from [query] rather than from storage.
///
/// Used by the generated `DerivedN` extensions, not meant to be called
/// directly.
@internal
S derivedTable<S extends Schema<R>, R>(
  String name,
  S Function(SchemaBuilder<R>) builder,
  Query<dynamic> query,
) =>
    Table<S, R>._(name, builder, derivedFrom: query).schema;

/// {@template table}
/// A table holds all the data related to building and querying tables.
///
/// The schema reference instance [S] holds the column-reference fields. Rows
/// are produced by invoking [Schema.fromRow] inside [create].
/// {@endtemplate}
class Table<S extends Schema<R>, R> implements Selectable<R> {
  /// {@macro table}
  Table._(this.name, this.builder, {this.alias, this.dialect, this.derivedFrom})
      : columns = [],
        indexes = [],
        checks = [] {
    schema = builder(SchemaBuilder<R>(this));
  }

  /// The name of the table.
  final String name;

  /// Optional alias used when this table is referenced in a join.
  final String? alias;

  /// The dialect this table belongs to.
  final SqlDialect? dialect;

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

  /// The table-level CHECK constraints defined on this table.
  final List<Check> checks;

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

  /// The rows a query returns, standing where a table would.
  final Query<dynamic>? derivedFrom;

  /// Create an aliased instance of the table.
  Table<S, R> aliased(String alias) =>
      Table<S, R>._(name, builder, alias: alias, dialect: dialect);

  /// This table's shape over [query]'s rows instead of its own.
  Table<S, R> asDerived(Query<dynamic> query) => Table<S, R>._(
        name,
        builder,
        alias: alias,
        dialect: dialect,
        derivedFrom: query,
      );

  /// Returns the values of a row [instance] in column order.
  List<dynamic> values(dynamic instance) {
    if (instance is! R) {
      throw StateError('Only $R rows can be converted to values');
    }
    return [...columns.map((c) => c.encode(c.readValueOf(instance)))];
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
    ColumnOr<V>? defaultValue,
  }) {
    if (defaultValue is Column) {
      throw ArgumentError.value(
        defaultValue,
        'defaultValue',
        'cannot be another column',
      );
    }
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

  /// Adds a table-level CHECK constraint to the table.
  void addCheck(Check check) => checks.add(check);

  /// The column named [name].
  ///
  /// Throws a [StateError] if the table has no such column.
  Column<R, dynamic> operator [](String name) =>
      columns.firstWhere((c) => c.name == name);
}
