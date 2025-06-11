import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  TextColumn text(
    String name,
    String Function(S) valueOf, {
    required String value,
  }) {
    return column(TextColumn.new, valueOf, name: name, value: value);
  }
}

extension type TextColumn(String _) implements ColumnType<String>, String {
  /// String like [value].
  SQL like(String value) => SQL($, ' LIKE ', value);

  /// String equals [value].
  SQL equals(String value) => SQL($, ' = ', value);
}
