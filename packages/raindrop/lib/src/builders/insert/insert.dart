import 'package:raindrop/raindrop.dart';

export 'insert_builder.dart';
export 'insert_values_builder.dart';

/// {@template insert}
/// Defines an insert statement.
/// {@endtemplate}
class Insert<S extends Schema<R>, R, V> extends Query<S, V> {
  /// {@macro insert}
  const Insert({
    required this.into,
    required this.values,
  });

  /// The table to insert into.
  final Table<S, R> into;

  /// The row values to insert.
  final List<R> values;
}
