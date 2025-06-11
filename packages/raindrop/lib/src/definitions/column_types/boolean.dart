import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  BooleanColumn boolean(
    String name,
    bool Function(S) valueOf, {
    required bool value,
  }) {
    return column(BooleanColumn.new, valueOf, name: name, value: value);
  }
}

extension type BooleanColumn(bool _) implements ColumnType<bool>, bool {
  /// Row value of column is true.
  SQL isTrue() => SQL($, ' = ', 1);

  /// Row value of column is false.
  SQL isFalse() => SQL($, ' = ', 0);
}
