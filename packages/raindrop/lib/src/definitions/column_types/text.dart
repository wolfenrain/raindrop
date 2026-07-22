import 'package:raindrop/raindrop.dart';

extension StringOperators<V extends String?> on ColumnOf<V> {
  /// String like [value].
  SQL like(ColumnOr<String> value) => SQL([this, const RawSQL('LIKE'), value]);
}
