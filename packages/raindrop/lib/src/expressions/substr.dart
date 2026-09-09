import 'package:raindrop/raindrop.dart';

/// `SUBSTR(value, start[, length])`. The result is nullable when [value] is.
Substr<V> substr<V extends String?>(
  ColumnOr<V> value,
  int start, [
  int? length,
]) =>
    Substr<V>(value, start, length);

/// {@template substr}
/// The `SUBSTR` function: [length] characters of [value] from [start], or
/// the rest of [value] without a [length].
/// {@endtemplate}
class Substr<V extends String?> extends Expression<V> {
  /// {@macro substr}
  Substr(this.value, this.start, [this.length]);

  /// The text to cut from.
  final ColumnOr<V> value;

  /// The 1-based position to start at.
  final int start;

  /// The number of characters to take.
  final int? length;

  @override
  SQL build() => SQL.function('SUBSTR', [
        value,
        start,
        if (length case final length?) length,
      ]);
}
