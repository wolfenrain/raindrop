import 'package:raindrop/raindrop.dart';

extension TextColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> text<W extends String?>(String name, Field<R, W> field) {
    return column<String, W>(name, field, sqlType: 'TEXT');
  }

  ColumnType<W> textArray<W extends List<String>?>(
    String name,
    Field<R, W> field,
  ) {
    return column<List<String>, W>(name, field, sqlType: 'TEXT[]');
  }
}
