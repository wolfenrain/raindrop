import 'package:raindrop/raindrop.dart';

/// `REPLACE(value, from, to)`. The result is nullable when [value] is.
Replace<V> replace<V extends String?>(
  ColumnOr<V> value, {
  required ColumnOr<String> from,
  required ColumnOr<String> to,
}) =>
    Replace<V>(value, from: from, to: to);

/// {@template replace}
/// The `REPLACE` function: [value] with every [from] replaced by [to].
/// {@endtemplate}
class Replace<V extends String?> extends Expression<V> {
  /// {@macro replace}
  Replace(this.value, {required this.from, required this.to});

  /// The text to search.
  final ColumnOr<V> value;

  /// The text to find.
  final ColumnOr<String> from;

  /// The text to put in its place.
  final ColumnOr<String> to;

  @override
  SQL build() => SQL.function('REPLACE', [value, from, to]);
}
