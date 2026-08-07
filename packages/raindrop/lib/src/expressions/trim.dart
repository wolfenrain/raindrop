import 'package:raindrop/raindrop.dart';

/// SQL `TRIM(value)`, [value] with surrounding whitespace removed.
Trim trim(ColumnOr<String?> value) => Trim(value);

/// {@template trim}
/// SQL `TRIM(value)`.
/// {@endtemplate}
class Trim extends Expression<String> {
  /// {@macro trim}
  Trim(this.value);

  /// What is being trimmed.
  final ColumnOr<String?> value;

  @override
  SQL build() => SQL.function('TRIM', [value]);
}
