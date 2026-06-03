import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<R> on SchemaBuilder<R> {
  T text<T extends TextColumn?>(
    String name,
    Field<R, String> field,
  ) {
    return column(TextColumn.new, name, field, sqlType: 'TEXT') as T;
  }

  T textArray<T extends TextArrayColumn?>(
    String name,
    Field<R, List<String>> field,
  ) {
    return column(TextArrayColumn.new, name, field, sqlType: 'TEXT[]')
        as T;
  }
}

extension type TextColumn(Column<dynamic, String> _)
    implements ColumnType<String> {}

extension type TextArrayColumn(Column<dynamic, List<String>> _)
    implements ColumnType<List<String>> {}
