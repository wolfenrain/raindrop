import 'package:raindrop/raindrop.dart';

/// {@template count}
/// SQL `COUNT(value)`.
/// {@endtemplate}
class Count<V> extends Expression<int> {
  /// {@macro count}
  Count(this.value);

  /// The column being counted.
  final ColumnOf<V> value;

  @override
  SQL build() => SQL.function('COUNT', [value.$]);
}
