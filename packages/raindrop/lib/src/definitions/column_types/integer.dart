import 'package:raindrop/raindrop.dart';

extension IntColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  IntColumn integer(
    String name,
    int Function(S) valueOf, {
    required int? value,
  }) {
    return column(IntColumn.new, valueOf, name: name, value: value ?? -1);
  }
}

extension type IntColumn(int _) implements ColumnType<int>, int {
  /// Row value of column equals [value].
  SQL equals(int value) => SQL($, ' = ', value);

  /// Row value of column is greater than [value].
  SQL greaterThan(int value) => SQL($, ' > ', value);

  /// Row value of column is greater than or equal [value].
  SQL greaterThanOrEqual(int value) => SQL($, ' >= ', value);

  /// Row value of column is greater than [value].
  SQL operator >(int value) => greaterThan(value);

  /// Row value of column is greater than or equal [value].
  SQL operator >=(int value) => greaterThanOrEqual(value);

  /// Row value of column is less than [value].
  SQL lessThan(int value) => SQL($, ' < ', value);

  /// Row value of column is less than or equal [value].
  SQL lessThanOrEqual(int value) => SQL($, ' <= ', value);

  /// Row value of column is less than [value].
  SQL operator <(int value) => lessThan(value);

  /// Row value of column is less than or equal [value].
  SQL operator <=(int value) => lessThanOrEqual(value);
}
