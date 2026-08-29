import 'package:raindrop/raindrop.dart';

/// SQL `REPLACE(value, from, to)`, every occurrence of [from] in [value]
/// replaced with [to].
Replace replace(
  ColumnOr<String?> value, {
  required ColumnOr<String?> from,
  required ColumnOr<String?> to,
}) =>
    Replace(value, from: from, to: to);

/// {@template replace}
/// SQL `REPLACE(value, from, to)`.
/// {@endtemplate}
class Replace extends Expression<String> {
  /// {@macro replace}
  Replace(this.value, {required this.from, required this.to});

  /// What is being rewritten.
  final ColumnOr<String?> value;

  /// The text being replaced.
  final ColumnOr<String?> from;

  /// The text every [from] becomes.
  final ColumnOr<String?> to;

  @override
  SQL build() => SQL.function('REPLACE', [value, from, to]);
}
