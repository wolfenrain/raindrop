import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<R> on SchemaBuilder<R> {
  T text<T extends TextColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? defaultValue,
  }) {
    return column<TextColumn, String, W>(
      TextColumn.new,
      name,
      field,
      sqlType: 'TEXT',
      defaultValue: defaultValue,
    ) as T;
  }

  T textArray<T extends TextArrayColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? defaultValue,
  }) {
    return column<TextArrayColumn, List<String>, W>(
      TextArrayColumn.new,
      name,
      field,
      sqlType: 'TEXT[]',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type TextColumn(Column<dynamic, String> _)
    implements ColumnType<String> {}

extension type TextArrayColumn(Column<dynamic, List<String>> _)
    implements ColumnType<List<String>> {}
