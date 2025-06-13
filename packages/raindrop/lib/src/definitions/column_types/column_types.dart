import 'dart:async';
import 'dart:convert';

import 'package:raindrop/raindrop.dart';

export 'double.dart';
export 'integer.dart';
export 'text.dart';

extension ColumnField<S extends Schema<S>> on SchemaBuilder<S> {
  V? column<T extends ColumnType<V?>, V extends Object>(
    T Function(V) typeBuilder,
    String name,
    Field<S, V> field,
    V? value, {
    ColumnTransformer<V, Object?>? transformer,
  }) {
    if (Zone.current[#table] case final Table<S> table) {
      ColumnType._typeToColumn[typeBuilder(value!)] = table.addColumn<V>(
        name,
        field,
        isNullable: null is V,
        transformer: transformer,
      );
    }

    if (Zone.current[#read] case final Map<String, dynamic> read) {
      final value = read[name];
      if (value == null) return null;
      if (transformer != null) return transformer.decode(value);
      return value as V;
    }

    return value;
  }

  I? transform<I extends Object, O extends Object>(
    ColumnType<I?> Function(I) typeBuilder,
    String name,
    Field<S, I> field,
    I? value, {
    required ColumnTransformer<I, O> transformer,
  }) {
    return column(typeBuilder, name, field, value, transformer: transformer);
  }
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

extension ColumnTypeX<T extends ColumnType<V>, V extends Object?> on T? {
  T? primaryKey({required bool autoIncrement}) {
    if (Zone.current[#table] case final Table table) {
      table.columns.last.isPrimaryKey = true;
    }

    return this;
  }
}

extension ColumnOperators<V extends Object?> on ColumnOf<V> {
  /// The column of this specific type.
  Column<Schema, V> get $ =>
      ColumnType._typeToColumn[this]! as Column<Schema, V>;

  /// Row value for column is in the list of [values].
  SQL inList(List<V> values) => SQL([$, 'IN', values]);

  /// Returns the count of what is being selected.
  ColumnTransform<Schema, int> count() => $.transform(
        SQL.function('COUNT', [$]),
      );

  /// Row value for column is null.
  SQL isNull() => SQL([$, const RawSQL('IS NULL')]);
}
