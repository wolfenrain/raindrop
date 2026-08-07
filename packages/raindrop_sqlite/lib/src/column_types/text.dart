import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> text<W extends String?>(
    String name,
    Field<R, W> field, {
    ColumnOr<String>? defaultValue,
  }) {
    return column<String, W>(
      name,
      field,
      sqlType: 'TEXT',
      defaultValue: defaultValue,
    );
  }
}
