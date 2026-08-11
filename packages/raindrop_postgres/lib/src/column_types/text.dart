import 'package:raindrop/raindrop.dart';

/// [String] columns that are stored as text values.
extension TextColumnDefinition<R> on SchemaBuilder<R> {
  /// A [String] column over `TEXT`.
  ColumnType<W> text<W extends String?>(String name, Field<R, W> field) {
    return column<String, W>(name, field, sqlType: 'TEXT');
  }

  /// A [List] of [String] column over `TEXT[]`.
  ColumnType<W> textArray<W extends List<String>?>(
    String name,
    Field<R, W> field,
  ) {
    return column<List<String>, W>(name, field, sqlType: 'TEXT[]');
  }
}
