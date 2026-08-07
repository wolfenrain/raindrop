import 'package:raindrop/raindrop.dart';

/// SQL `AVG(value)`, the mean of [value] across the group.
Avg avg(ColumnOr<num?> value) => Avg(value);

/// {@template avg}
/// SQL `AVG(value)`.
///
/// Always produces a floating point number, whatever went in, averaging
/// integers gives a fraction.
/// {@endtemplate}
class Avg extends Expression<double> {
  /// {@macro avg}
  Avg(this.value);

  /// The column or expression being averaged.
  final ColumnOr<num?> value;

  @override
  SQL build() => SQL.function('AVG', [value]);
}
