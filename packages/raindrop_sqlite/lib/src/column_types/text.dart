import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<R> on SchemaBuilder<R> {
  T text<T extends TextColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return column<TextColumn, String, W>(
      TextColumn.new,
      name,
      field,
      sqlType: sqlType ?? 'TEXT',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type TextColumn(Column<dynamic, String> _)
    implements ColumnType<String> {}
