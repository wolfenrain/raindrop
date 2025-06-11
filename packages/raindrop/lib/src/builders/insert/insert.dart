import 'package:raindrop/raindrop.dart';

export 'insert_builder.dart';
export 'insert_values_builder.dart';

/// {@template insert}
/// Defines an insert statement.
/// {@endtemplate}
class Insert<S extends Schema<S>, V> extends Query<S, V> {
  /// {@macro insert}
  const Insert({
    required this.into,
    required this.values,
  });

  /// The table to insert into.
  final Table<S> into;

  /// The values to insert.
  final List<V> values;
}
