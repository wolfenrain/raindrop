import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<R> on SchemaBuilder<R> {
  T text<T extends TextColumn?>(
    String name,
    Field<R, String> field,
  ) {
    return column(TextColumn.new, name, field, sqlType: 'TEXT') as T;
  }
}

extension type TextColumn(Column<dynamic, String> _)
    implements ColumnType<String> {}
