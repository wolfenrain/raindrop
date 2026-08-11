import 'dart:async';

import 'package:meta/meta.dart';
import 'package:raindrop/raindrop.dart';

/// A column value of type [V], accepted directly or as a [Future].
typedef ColumnOr<V> = FutureOr<V>;

/// Row field getter for schema [R].
///
/// Use [W] such that `null is W` matches the column's nullability
/// (`int` vs `int?`, `ColumnType<int>` vs `ColumnType<int?>`).
/// It's inferred from the accessor's return type and drives
/// [Column.isNullable].
typedef Field<R, W extends Object?> = W Function(R);

/// A single column of a [Table], usable as an operand in queries and as a
/// selectable.
///
/// [R] is the row type of the owning table and [V] the Dart value type of
/// the column.
class Column<R, V extends Object?> with SqlOperand<V> implements Selectable<V> {
  /// Creates a column named [name] on [table].
  Column(
    this.table,
    this.name, {
    Function? valueOf,
    this.isNullable = false,
    this.isPrimaryKey = false,
    this.transformer,
    this.sqlType,
    this.autoIncrement = false,
    this.defaultValue,
    this.foreignKeyReference,
  }) : _valueOf = valueOf;

  /// The table of the column.
  final Table<Schema<dynamic>, dynamic> table;

  /// The name of the column.
  final String name;

  /// `V? Function(R)`, stored as [Function] so callers can pass in
  /// `V? Function(SpecificR)` without contravariant-cast issues.
  final Function? _valueOf;

  /// Reads this column's value from row [r] via the accessor given at
  /// construction, without any of its type data.
  @internal
  // ignore: avoid_dynamic_calls we know the contract of the function
  dynamic readValueOf(Object? r) => _valueOf!(r as R) as dynamic;

  /// A column's transformer for Dart to SQL conversion.
  @override
  final ColumnTransformer<V, Object?>? transformer;

  /// If the column is a primary key.
  bool isPrimaryKey;

  /// If the column is nullable;
  final bool isNullable;

  /// The SQL type name (e.g., 'INTEGER', 'TEXT', 'TIMESTAMP').
  final String? sqlType;

  /// Whether this column auto-increments (for primary keys).
  bool autoIncrement;

  /// The column's default: a value in the column's own type, or an
  /// expression the database evaluates.
  ///
  /// `null` means the column has no default.
  final ColumnOr<V>? defaultValue;

  /// Foreign key reference for this column.
  ForeignKeyReference? foreignKeyReference;

  // TODO(wolfen): should be on ColumnType
  /// Returns the nullable version of this column.
  Column<R, V?> get nullable => Column(
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
  ColumnAlias<R, V> as(String alias) {
    return ColumnAlias<R, V>._(
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

  @override
  String toString() {
    return 'Column<$V>(name: $name)';
  }
}

/// Provides alias information of a column.
class ColumnAlias<R, V extends Object?> extends Column<R, V> {
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
