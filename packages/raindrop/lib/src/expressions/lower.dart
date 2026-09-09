import 'package:raindrop/raindrop.dart';

/// `LOWER(value)`. The result is nullable when [value] is.
Lower<V> lower<V extends String?>(ColumnOr<V> value) => Lower<V>(value);

/// {@template lower}
/// The `LOWER` function: [value] in lower case.
/// {@endtemplate}
class Lower<V extends String?> extends Expression<V> {
  /// {@macro lower}
  Lower(this.value);

  /// The text to convert.
  final ColumnOr<V> value;

  @override
  SQL build() => SQL.function('LOWER', [value]);
}
