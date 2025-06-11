import 'dart:async';

import 'package:raindrop/raindrop.dart';

export 'date_time.dart';
export 'float.dart';
export 'integer.dart';
export 'primary_key.dart';
export 'text.dart';

extension ColumnField<S extends Schema<S>> on SchemaBuilder<S> {
  T column<T extends ColumnType<V>, V extends Object>(
    T Function(V) typeBuilder,
    V Function(S) valueOf, {
    required String name,
    required V value,
    bool isNullable = false,
    bool isPrimaryKey = false,
  }) {
    if (Zone.current[#table] case final Table<S> table) {
      ColumnType._typeToColumn[typeBuilder(value)] = table.addColumn<V>(
        name,
        valueOf,
        isNullable: isNullable,
        isPrimaryKey: isPrimaryKey,
      );
    }

    if (Zone.current[#write] case final Map<String, dynamic> write) {
      return typeBuilder(write[name] = value);
    }

    if (Zone.current[#read] case final Map<String, dynamic> read) {
      return typeBuilder(read[name] as V);
    }

    return typeBuilder(value);
  }
}

extension type ColumnType<V extends Object?>._(V _) {
  /// The column of this specific type.
  Column<Schema, V> get $ => _typeToColumn[this]! as Column<Schema, V>;

  /// Make the column updateable by [value].
  UpdateableColumn<S, V> set<S extends Schema<S>>(V value) => $.set(value);

  /// Row value for column is in the list of [values].
  SQL inList(List<V> values) => SQL($, ' IN ', values);

  /// Returns the count of what is being selected.
  ColumnTransform<Schema, int> count() => $.transform(
        SQL.multiple([const RawSQL('COUNT('), $, const RawSQL(')')]),
      );

  static final Map<ColumnType, Column> _typeToColumn = {};
}

extension NullableType<V extends Object?> on ColumnType<V?> {
  /// Row value for column is null.
  SQL isNull() => SQL.multiple([$, const RawSQL(' IS NULL')]);
}
