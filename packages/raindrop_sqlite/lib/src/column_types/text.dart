import 'package:raindrop/raindrop.dart';

/// Strings, stored as a TEXT.
extension TextColumnDefinition<R> on SchemaBuilder<R> {
  /// A [String] column, optionally with a [defaultValue].
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
