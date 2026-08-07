import 'package:raindrop/raindrop.dart';

/// SQL `LENGTH(value)`, the character count of [value].
Length length(ColumnOr<String?> value) => Length(value);

/// {@template length}
/// SQL `LENGTH(value)`.
/// {@endtemplate}
class Length extends Expression<int> {
  /// {@macro length}
  Length(this.value);

  /// What is being measured.
  final ColumnOr<String?> value;

  @override
  SQL build() => SQL.function('LENGTH', [value]);
}
