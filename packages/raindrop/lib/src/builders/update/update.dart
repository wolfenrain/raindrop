import 'package:raindrop/raindrop.dart';

export 'update_builder.dart';
export 'update_setting_builder.dart';

/// {@template update}
/// Describes an update query.
/// {@endtemplate}
class Update<S extends Schema<R>, R, V> extends Query<S, V> {
  /// {@macro update}
  const Update({
    required this.set,
    required this.table,
    this.where,
  });

  /// The rows/entities to set.
  final Updateable<Object> set;

  /// The table to update.
  final Table<S, R> table;

  /// Any filter applied to the update query.
  final Filter? where;
}
