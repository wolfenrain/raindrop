// ignore_for_file: strict_raw_type

import 'package:raindrop/raindrop.dart';

/// Interface for making a class updateable.
///
/// Used internally.
abstract interface class Updateable<S extends Schema<S>, V> {
  /// Read the given updatable into proper data of the type [V].
  static V read<S extends Schema<S>, V>(
    Updateable<S, V> item,
    Map<String, dynamic> data,
    AliasRegistry registry,
  ) {
    if (item is UpdatableTable<S>) {
      // item.table;
    } else if (item is UpdateableColumn<S, V>) {
      return data[registry.name(item.column)] as V;
    }

    throw UnsupportedError('$item');
  }
}

/// {@template updateable_column}
/// A column that can be updated.
/// {@endtemplate}
class UpdateableColumn<S extends Schema<S>, V> implements Updateable<S, V> {
  /// {@macro updateable_column}
  const UpdateableColumn(this.column, this.value);

  /// The column in question.
  final Column<S, V> column;

  /// The value to update it too.
  final V value;
}

/// {@template updateable_table}
/// A table that can be updated.
/// {@endtemplate}
class UpdatableTable<S extends Schema<S>> implements Updateable<S, S> {
  /// {@macro updateable_table}
  const UpdatableTable(this.table, this.value);

  /// The table in question.
  final Table<S> table;

  /// The entity to update it with.
  final S value;
}

/// Provide a set method to a column to update a column.
extension UpdateColumn<V> on Column<Schema, V> {
  /// Make the column updateable by [value].
  UpdateableColumn<S, V> set<S extends Schema<S>>(V value) {
    return UpdateableColumn(this as Column<S, V>, value);
  }
}

/// Provide a set method to a table to update a record.
extension UpdateRecord<S extends Schema<S>> on Table<S> {
  /// Make the table updateable by [value].
  UpdatableTable<S> set(S value) => UpdatableTable(this, value);
}

/// {@template updatable_result}
/// List of updateable results
///
/// Used internally.
/// {@endtemplate}
class UpdateableResult<S extends Schema<S>, V> implements Updateable<S, V> {
  /// {@macro updatable_result}
  const UpdateableResult(this._updating);

  final List<Updateable> _updating;

  /// The updateable items.
  Iterable<Updateable> get items sync* {
    for (final update in _updating) {
      if (update is UpdateableResult) {
        yield* update.items;
      } else if (update is UpdateableColumn) {
        yield update;
      } else if (update is UpdatableTable) {
        yield update;
      } else {
        yield update;
      }
    }
  }
}
