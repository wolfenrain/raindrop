import 'package:raindrop/raindrop.dart';

/// `TRIM(value)`. The result is nullable when [value] is.
Trim<V> trim<V extends String?>(ColumnOr<V> value) => Trim<V>(value);

/// {@template trim}
/// The `TRIM` function: [value] without leading and trailing whitespace.
/// {@endtemplate}
class Trim<V extends String?> extends Expression<V> {
  /// {@macro trim}
  Trim(this.value);

  /// The text to trim.
  final ColumnOr<V> value;

  @override
  SQL build() => SQL.function('TRIM', [value]);
}
