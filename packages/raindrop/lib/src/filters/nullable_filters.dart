import 'package:raindrop/raindrop.dart';

/// Extension that providers nullable-based filters on columns.
extension NullableFilters<S extends Schema<S>, V extends Object?>
    on Column<S, V> {
  /// Row value for column is null.
  SQL isNull() => SQL.multiple([this, const RawSQL(' IS NULL')]);

  /// Row value for column equals [value].
  SQL equalsColumn(Column<S, V> value) => SQL(this, ' = ', value);

  /// Row value for column is in the list of [values].
  SQL inList(List<V> values) => SQL(this, ' IN ', values);
}
