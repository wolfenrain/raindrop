import 'package:raindrop/raindrop.dart';

export 'joins.dart';
export 'select_builder.dart';
export 'select_from_builder.dart';

/// {@template select}
/// Describes a select query.
/// {@endtemplate}
class Select<S extends Schema<R>, R, V> extends Query<S, V> {
  /// {@macro select}
  const Select({
    required this.selecting,
    required this.from,
    this.joins = const [],
    this.where,
    this.limit,
    this.offset,
    this.groupBy,
  });

  /// The rows and/or entities the query is selecting.
  final Selectable<V> selecting;

  /// Where it is selecting from.
  final Table<S, R> from;

  /// Any joins added to the select.
  final List<Join> joins;

  /// The where filter of the query.
  final Filter? where;

  /// The limit of rows to be selected.
  final int? limit;

  /// The offset from the start.
  final int? offset;

  /// The group by clause of the query.
  final Selectable<dynamic>? groupBy;
}
