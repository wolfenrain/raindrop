import 'package:raindrop/raindrop.dart';

extension StringOperators<V extends String?> on ColumnOf<V> {
  /// String like [value].
  SQL like(ColumnOr<String> value) => SQL([this, const RawSQL('LIKE'), value]);

  /// Lexicographic ordering.
  SQL greaterThan(ColumnOr<String> value) => SQL([this, Op.greaterThan, value]);

  /// Lexicographic ordering.
  SQL greaterThanOrEqual(ColumnOr<String> value) =>
      SQL([this, Op.greaterThanOrEqual, value]);

  /// Lexicographic ordering.
  SQL lessThan(ColumnOr<String> value) => SQL([this, Op.lessThan, value]);

  /// Lexicographic ordering.
  SQL lessThanOrEqual(ColumnOr<String> value) =>
      SQL([this, Op.lessThanOrEqual, value]);
}
