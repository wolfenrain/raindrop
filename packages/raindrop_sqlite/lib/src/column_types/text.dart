import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T text<T extends TextColumn?>(
    String name,
    Field<S, String> field,
    String? value,
  ) {
    return column(TextColumn.new, name, field, value, sqlType: 'TEXT') as T;
  }
}

extension type TextColumn(String _) implements ColumnType<String>, String {}
