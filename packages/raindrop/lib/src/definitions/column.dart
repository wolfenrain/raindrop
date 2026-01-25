import 'package:raindrop/raindrop.dart';

typedef Field<S extends Schema<S>?, V extends Object> = V? Function(S);

class Column<S extends Schema<S>?, V extends Object?> implements Selectable<V> {
  Column(
    this.table,
    this.name, {
    this.valueOf,
    this.isNullable = false,
    this.isPrimaryKey = false,
    this.transformer,
    this.sqlType,
    this.autoIncrement = false,
    this.defaultValue,
    this.foreignKeyReference,
  });

  /// The table of the column.
  final Table table;

  /// The name of the column.
  final String name;

  final V? Function(S)? valueOf;

  /// Same as [valueOf] but without any of it's type data.s
  ///
  /// This is useful for internal use mostly.
  dynamic readValueOf(Schema<Object?> s) => valueOf!(s as S) as dynamic;

  Object? encode(V? input) {
    if (input == null) return null;

    return switch (transformer) {
      final ColumnTransformer transformer => transformer.encode(input),
      _ => input
    };
  }

  V? decode(Object? input) {
    if (input == null) return null;

    return switch (transformer) {
      final ColumnTransformer transformer => transformer.decode(input),
      _ => input
    } as V?;
  }

  final ColumnTransformer<V, Object?>? transformer;

  /// If the column is a primary key.
  bool isPrimaryKey;

  /// If the column is nullable;
  final bool isNullable;

  /// The SQL type name (e.g., 'INTEGER', 'TEXT', 'TIMESTAMP').
  final String? sqlType;

  /// Whether this column auto-increments (for primary keys).
  bool autoIncrement;

  /// Default value expression for the column.
  final String? defaultValue;

  /// Foreign key reference for this column.
  ForeignKeyReference? foreignKeyReference;

  // TODO: should be on ColumnType
  /// Returns the nullable version of this column.
  Column<S, V?> get nullable => Column(
        table,
        name,
        isNullable: true,
        isPrimaryKey: isPrimaryKey,
        sqlType: sqlType,
        autoIncrement: autoIncrement,
        defaultValue: defaultValue,
        foreignKeyReference: foreignKeyReference,
      );

  /// Make an alias of the column.
  ColumnAlias<S, V> as(String alias) {
    return ColumnAlias<S, V>._(
      table,
      name,
      isNullable: isNullable,
      isPrimaryKey: isPrimaryKey,
      alias: alias,
      sqlType: sqlType,
      autoIncrement: autoIncrement,
      defaultValue: defaultValue,
      foreignKeyReference: foreignKeyReference,
    );
  }

  ColumnTransform<S, O> transform<O extends Object?>(SQL sql) {
    return ColumnTransform<S, O>(table, name, sql);
  }

  @override
  String toString() {
    return 'Column<$V>(name: $name)';
  }
}

/// Provides alias information of a column.
class ColumnAlias<S extends Schema<S>?, V extends Object?>
    extends Column<S, V> {
  ColumnAlias._(
    super.table,
    super.name, {
    required super.isNullable,
    required super.isPrimaryKey,
    required this.alias,
    super.sqlType,
    super.autoIncrement,
    super.defaultValue,
    super.foreignKeyReference,
  });

  /// The alias of the column.
  final String alias;
}

/// {@template column_transform}
/// Provides transform information of a column.
/// {@endtemplate}
class ColumnTransform<S extends Schema<S>?, V extends Object?>
    extends Column<S, V> {
  /// {@macro column_transform}
  ColumnTransform(super.table, super.name, this.sql);

  /// The SQL to transform with.
  final SQL sql;
}
