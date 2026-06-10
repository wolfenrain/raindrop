import 'package:raindrop/raindrop.dart';

/// SQL `COUNT(...)`.
///
/// `count()` produces `COUNT(*)` while `count(column)` produces `COUNT(column)`
/// The result is always an `int`, the counted column's type is irrelevant, so
/// this isn't generic (which also lets `count()` be called with no arguments).
Count<Object?> count([ColumnOf<Object?>? value]) => Count<Object?>(value);

/// {@template count}
/// SQL `COUNT(value)`, or `COUNT(*)` when [value] is null.
/// {@endtemplate}
class Count<V> extends Expression<int> {
  /// {@macro count}
  Count([this.value]);

  /// The column being counted, or null for `COUNT(*)`.
  final ColumnOf<V>? value;

  @override
  SQL build() => switch (value) {
        null => SQL([const RawSQL('COUNT(*)')]),
        final value => SQL.function('COUNT', [value])
      };
}
