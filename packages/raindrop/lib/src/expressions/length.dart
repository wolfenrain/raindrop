import 'package:raindrop/raindrop.dart';

/// `LENGTH(value)`.
///
/// The length of a `NULL` is `NULL`, which a non-nullable `int` cannot
/// carry. Give a nullable column a fallback with [coalesce] first.
Length length(ColumnOr<String> value) => Length(value);

/// {@template length}
/// The `LENGTH` function: the number of characters in [value].
/// {@endtemplate}
class Length extends Expression<int> {
  /// {@macro length}
  Length(this.value);

  /// The text to measure.
  final ColumnOr<String> value;

  @override
  SQL build() => SQL.function('LENGTH', [value]);
}
