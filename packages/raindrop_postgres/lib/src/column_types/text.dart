import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T text<T extends TextColumn?>(
    String name,
    Field<S, String> field,
    String? value,
  ) {
    return column(TextColumn.new, name, field, value, sqlType: 'TEXT') as T;
  }

  T textArray<T extends TextArrayColumn?>(
    String name,
    Field<S, List<String>> field,
    List<String>? value,
  ) {
    return column(TextArrayColumn.new, name, field, value, sqlType: 'TEXT[]')
        as T;
  }
}

extension type TextColumn(String _) implements ColumnType<String>, String {}
extension type TextArrayColumn(List<String> _)
    implements ColumnType<List<String>>, List<String> {}
