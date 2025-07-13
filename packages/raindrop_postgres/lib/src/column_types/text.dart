import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T text<T extends TextColumn?>(
    String name,
    Field<S, String> field,
    String? value,
  ) {
    return column(TextColumn.new, name, field, value) as T;
  }
}

extension TextArrayDefinition<S extends Schema<S>>
    on ColumnBuilder<S, TextColumn, String> {
  T array<T extends TextArrayColumn?>(
    String name,
    Field<S, List<String>> field,
    List<String>? value,
  ) {
    return column(TextArrayColumn.new, name, field, value) as T;
  }
}

extension type TextColumn(String _) implements ColumnType<String>, String {}
extension type TextArrayColumn(List<String> _)
    implements ColumnType<List<String>>, List<String> {}
