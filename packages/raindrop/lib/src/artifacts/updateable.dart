// ignore_for_file: strict_raw_type

import 'package:raindrop/raindrop.dart';

/// Interface for making a class updateable.
///
/// Used internally.
abstract interface class Updateable<V> {}

/// {@template updateable_column}
/// A column that can be updated.
/// {@endtemplate}
class UpdateableColumn<V> implements Updateable<V> {
  /// {@macro updateable_column}
  const UpdateableColumn(this.column, this.value);

  /// The column in question.
  final Column<dynamic, V> column;

  /// The value to update it too.
  final V value;
}

/// {@template updateable_table}
/// A table that can be updated.
/// {@endtemplate}
class UpdateableTable<S extends Schema<R>, R> implements Updateable<R> {
  /// {@macro updateable_table}
  const UpdateableTable(this.table, this.value);

  /// The table in question.
  final Table<S, R> table;

  /// The row to update it with.
  final R value;
}

/// {@template updateable_expression}
/// A column whose new value is the result of a SQL [Expression].
/// {@endtemplate}
class UpdateableExpression<V> implements Updateable<V> {
  /// {@macro updateable_expression}
  const UpdateableExpression(this.column, this.expression);

  /// The column being updated.
  final Column<dynamic, V> column;

  /// The expression producing the new value.
  final Expression<V> expression;
}

/// Provide a set method to a column to update a column.
extension UpdateColumn<V> on ColumnOf<V> {
  /// Set the column for a given row to [value].
  UpdateableColumn<V> to(V value) => UpdateableColumn(this!, value);

  /// Set the column to the result of a SQL [expression].
  UpdateableExpression<V> toExpression(Expression<V> expression) =>
      UpdateableExpression(this!, expression);
}

/// {@template updateable_result}
/// List of updateable results
///
/// Used internally.
/// {@endtemplate}
class UpdateableResult<V> implements Updateable<V> {
  /// {@macro updateable_result}
  const UpdateableResult(this.updating);

  /// The updated items.
  final List<Updateable> updating;
}
