import 'package:raindrop/raindrop.dart';

/// Sort direction for an `ORDER BY` term, used as the value in the
/// `orderBy({column: Order.asc, ...})` map.
enum Order {
  /// Ascending (`ASC`).
  asc,

  /// Descending (`DESC`).
  desc,
}

/// {@template order_by}
/// A single `ORDER BY` term.
///
/// [term] may be a column reference (`users.name`) or an [Expression]
/// (`min(users.score)`).
/// {@endtemplate}
class OrderBy {
  /// {@macro order_by}
  const OrderBy(this.term, {required this.descending});

  /// The column or expression being ordered on.
  final Selectable<dynamic> term;

  /// Whether to sort descending (`DESC`) or ascending (`ASC`) when false.
  final bool descending;
}
