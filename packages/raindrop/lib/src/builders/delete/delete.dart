import 'package:raindrop/raindrop.dart';

export 'delete_builder.dart';

/// {@template delete}
/// Defines a delete statement.
/// {@endtemplate}
class Delete<S extends Schema<R>, R, V> extends Query<S, V> {
  /// {@macro delete}
  const Delete({
    required this.from,
    this.where,
  });

  /// Table to delete from.
  final Table<S, R> from;

  /// The filter used to know what to delete.
  final Filter? where;
}
