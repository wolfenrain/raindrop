import 'package:raindrop/raindrop.dart';

export 'joins/inner_joins.dart';
export 'joins/left_joins.dart';
export 'joins/projection_joins.dart';
export 'joins/right_joins.dart';

/// {@template join}
/// Abstract class for defining joins.
/// {@endtemplate}
abstract class Join<S extends Schema<R>, R> {
  /// {@macro join}
  const Join(this.table, {required this.on});

  /// The table to join.
  final Table<S, R> table;

  /// The filter used for defining what to join on.
  final Filter on;
}

/// {@template inner_join}
/// Describes an inner join.
/// {@endtemplate}
class InnerJoin<S extends Schema<R>, R> extends Join<S, R> {
  /// {@macro inner_join}
  const InnerJoin(super.table, {required super.on});
}

/// {@template left_join}
/// Describes a left join.
/// {@endtemplate}
class LeftJoin<S extends Schema<R>, R> extends Join<S, R> {
  /// {@macro left_join}
  const LeftJoin(super.table, {required super.on});
}

/// {@template right_join}
/// Describes a right join.
/// {@endtemplate}
class RightJoin<S extends Schema<R>, R> extends Join<S, R> {
  /// {@macro right_join}
  const RightJoin(super.table, {required super.on});
}
