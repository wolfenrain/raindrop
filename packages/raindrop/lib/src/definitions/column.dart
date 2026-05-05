import 'dart:async';

import 'package:raindrop/raindrop.dart';

typedef ColumnOr<V> = FutureOr<V>;

/// Makes a [Column] usable as a [ColumnOr] operand by posing as a `Future<V>`.
///
/// This is a deliberate fiction: `ColumnOr<V>` is `FutureOr<V>` so a column
/// must satisfy `Future<V>` to be accepted alongside a literal `V`.
mixin ColumnOperand<V> implements Future<V> {
  static Never _notAFuture() => throw UnsupportedError(
        'A Column is not a real Future, it only poses as one so it can be '
        'used as a ColumnOr operand.',
      );

  @override
  Stream<V> asStream() => _notAFuture();

  @override
  Future<V> catchError(Function onError, {bool Function(Object error)? test}) =>
      _notAFuture();

  @override
  Future<R> then<R>(FutureOr<R> Function(V value) onValue,
          {Function? onError}) =>
      _notAFuture();

  @override
  Future<V> timeout(Duration timeLimit, {FutureOr<V> Function()? onTimeout}) =>
      _notAFuture();

  @override
  Future<V> whenComplete(FutureOr<void> Function() action) => _notAFuture();
}

/// Row field getter for schema [R]. Use [W] such that `null is W` matches
/// column nullability (e.g. [int] vs [int?], [IntColumn] vs [IntColumn?]).
typedef Field<R, W extends Object?> = W Function(R);

class Column<R, V extends Object?>
    with ColumnOperand<V>
    implements Selectable<V> {
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
  }) : valueOf = valueOf;

  /// The table of the column.
  final Table table;

  /// The name of the column.
  final String name;

  /// `V? Function(R)`, stored as [Function] so callers can pass in
  /// `V? Function(SpecificR)` without contravariant-cast issues.
  final Function? valueOf;

  /// Same as [valueOf] but without any of its type data.
  ///
  /// This is useful for internal use mostly.
  dynamic readValueOf(Object? r) => valueOf!(r as R) as dynamic;

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
