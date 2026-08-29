import 'package:raindrop/raindrop.dart';

/// SQL `SUBSTR(value, start, [length])`, the part of [value] that starts at
/// the 1-based [start], capped to [length] characters when given.
Substr substr(ColumnOr<String?> value, int start, [int? length]) =>
    Substr(value, start, length);

/// {@template substr}
/// SQL `SUBSTR(value, start, [length])`.
/// {@endtemplate}
class Substr extends Expression<String> {
  /// {@macro substr}
  Substr(this.value, this.start, [this.length]);

  /// What is being cut.
  final ColumnOr<String?> value;

  /// The 1-based position the part starts at.
  final int start;

  /// The most characters the part holds, unbounded when null.
  final int? length;

  @override
  SQL build() => SQL.function('SUBSTR', [
        value,
        start,
        if (length case final length?) length,
      ]);
}
