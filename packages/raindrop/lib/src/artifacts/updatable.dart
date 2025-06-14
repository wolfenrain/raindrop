// ignore_for_file: strict_raw_type

import 'package:raindrop/raindrop.dart';

/// Interface for making a class updateable.
///
/// Used internally.
abstract interface class Updateable<S extends Schema<S>, V> {}

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
class UpdateableTable<S extends Schema<S>> implements Updateable<S, S> {
  /// {@macro updateable_table}
  const UpdateableTable(this.table, this.value);

  /// The table in question.
  final Table<S> table;

  /// The entity to update it with.
  final S value;
}

/// Provide a set method to a column to update a column.
extension UpdateColumn<V> on ColumnOf<V> {
  /// Make the column updateable by [value].
  UpdateableColumn<S, V> set<S extends Schema<S>>(V value) =>
      UpdateableColumn($ as Column<S, V>, value);
}

/// Provide a set method to a table to update an instance.
extension UpdateTable<S extends Schema<S>> on S {
  /// Make the table updateable by [value].
  UpdateableTable<S> set(S value) => UpdateableTable($, value);
}

/// {@template updatable_result}
/// List of updateable results
///
/// Used internally.
/// {@endtemplate}
class UpdateableResult<S extends Schema<S>, V> implements Updateable<S, V> {
  /// {@macro updatable_result}
  const UpdateableResult(this.updating);

  /// The updated items.
  final List<Updateable> updating;
}
