import 'package:raindrop/raindrop.dart';

/// `UPPER(value)`. The result is nullable when [value] is.
Upper<V> upper<V extends String?>(ColumnOr<V> value) => Upper<V>(value);

/// {@template upper}
/// The `UPPER` function: [value] in upper case.
/// {@endtemplate}
class Upper<V extends String?> extends Expression<V> {
  /// {@macro upper}
  Upper(this.value);

  /// The text to convert.
  final ColumnOr<V> value;

  @override
  SQL build() => SQL.function('UPPER', [value]);
}
