import 'package:raindrop/raindrop.dart';

extension StringOperators on ColumnOf<String> {
  /// String like [value].
  SQL like(String value) => SQL([$, const RawSQL('LIKE'), value]);

  /// String equals [value].
  SQL equals(String value) => SQL([$, Op.equals, value]);
}
