import 'package:raindrop/raindrop.dart';

extension StringOperators on ColumnOf<String> {
  /// String like [value].
  SQL like(ColumnOr<String> value) => SQL([this, const RawSQL('LIKE'), value]);

  /// String equals [value].
  SQL equals(ColumnOr<String> value) => SQL([this, Op.equals, value]);
}
