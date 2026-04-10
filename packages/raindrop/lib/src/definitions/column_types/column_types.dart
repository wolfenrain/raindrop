import 'dart:async';

import 'package:raindrop/raindrop.dart';

export 'double.dart';
export 'integer.dart';
export 'text.dart';

extension ColumnBuilderProvider<S extends Schema<S>> on SchemaBuilder<S> {
  V? column<T extends ColumnType<V?>, V extends Object>(
    T Function(V) typeBuilder,
    String name,
    Field<S, V> field,
    V? value, {
    String? sqlType,
    String? defaultValue,
  }) {
    return _column<S, T, V>(
      typeBuilder,
      name,
      field,
      value,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }

  I? custom<I extends Object, O extends Object>(
    ColumnType<I?> Function(I) typeBuilder,
    String name,
    Field<S, I> field,
    I? value, {
    required ColumnTransformer<I, O> transformer,
    String? sqlType,
    String? defaultValue,
  }) {
    return _column(
      typeBuilder,
      name,
      field,
      value,
      transformer: transformer,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }
}

V? _column<S extends Schema<S>, T extends ColumnType<V?>, V extends Object>(
  T Function(V) typeBuilder,
  String name,
  Field<S, V> field,
  V? value, {
  ColumnTransformer<V, Object?>? transformer,
  String? sqlType,
  String? defaultValue,
}) {
  // If the zone has a table, start building up the registry.
  if (Zone.current[#table] case final Table<S> table) {
    if (value == null) {
      throw StateError('Provide a fake value for $S.$name');
    }
    ColumnType._typeToColumn[typeBuilder(value)] = table.addColumn<V>(
      name,
      field,
      isNullable: null is V,
      transformer: transformer,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }

  // If the zone has read data, read the value from there.
  if (Zone.current[#read] case final Map<String, dynamic> read) {
    final value = read[name];
    if (value == null) return null;
    return value as V;
  }

  return value;
}

abstract class ColumnTransformer<I, O> {
  const ColumnTransformer();

  O encode(I input);

  I decode(O input);
}

typedef ColumnOf<V extends Object?> = ColumnType<V>?;

extension type ColumnType<V extends Object?>._(V _) {
  static final Map<ColumnType, Column> _typeToColumn = {};
}

extension ColumnTypeX<V extends Object?> on ColumnType<V>? {
  // TODO: validate if this works
  /// Returns the nullable version of this column.
  ColumnType<V?> get nullable => this as ColumnType<V>;
}

extension PrimaryColumn<T extends ColumnType<V>, V extends Object?> on T? {
  /// Marks this column as the primary key (no auto-increment).
  T? primaryKey() {
    if (Zone.current[#table] case final Table table) {
      table.columns.last
        ..isPrimaryKey = true
        ..autoIncrement = false;
    }

    return this;
  }
}

extension PrimaryColumnNonNull<T extends ColumnType<V>, V extends Object?>
    on T {
  /// Marks this column as the primary key (no auto-increment).
  T primaryKey() => PrimaryColumn(this).primaryKey()!;
}

extension PrimaryColumnInteger<T extends ColumnType<int>> on T? {
  /// Marks this integer column as the primary key, optionally with auto-increment.
  T? primaryKey({required bool autoIncrement}) {
    if (Zone.current[#table] case final Table table) {
      table.columns.last
        ..isPrimaryKey = true
        ..autoIncrement = autoIncrement;
    }

    return this;
  }
}

extension PrimaryColumnIntegerNonNull<T extends ColumnType<int>> on T {
  /// Marks this integer column as the primary key, optionally with auto-increment.
  T primaryKey({required bool autoIncrement}) =>
      PrimaryColumnInteger(this).primaryKey(autoIncrement: autoIncrement)!;
}

extension ColumnOperators<V extends Object?> on ColumnOf<V> {
  /// Make an alias of the column.
  ColumnAlias<Schema<Object?>, V> as(String alias) => $.as(alias);

  /// The column of this specific type.
  Column<Schema<Object?>, V> get $ {
    final column = ColumnType._typeToColumn[this];
    if (column == null) {
      throw StateError('Using an instance value instead of a schema!');
    }
    return column as Column<Schema<Object?>, V>;
  }

  /// Row value for column is in the list of [values].
  SQL inList(List<V> values) => SQL([$, 'IN', values]);

  /// Returns the count of what is being selected.
  ColumnTransform<Schema<Object?>, int> count() => $.transform(
        SQL.function('COUNT', [$]),
      );

  /// Row value for column is null.
  SQL isNull() => SQL([$, const RawSQL('IS NULL')]);
}

/// Extension to add foreign key references to columns.
extension ReferencesColumn<T extends ColumnType<V>, V extends Object?> on T? {
  /// Adds a foreign key reference to another column.
  ///
  /// Example:
  /// ```dart
  /// $.integer('owner_id', (s) => s.ownerId, userId)
  ///     .references(() => users.id, onDelete: ReferentialAction.cascade)
  /// ```
  T references(
    ColumnOf Function() columnGetter, {
    ReferentialAction? onDelete,
    ReferentialAction? onUpdate,
  }) {
    if (Zone.current[#table] case final Table table) {
      table.columns.last.foreignKeyReference = ForeignKeyReference(
        referencedColumnGetter: () => columnGetter().$,
        onDelete: onDelete,
        onUpdate: onUpdate,
      );
    }
    return this as T;
  }
}
