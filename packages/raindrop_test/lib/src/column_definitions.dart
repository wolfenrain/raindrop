import 'package:raindrop/raindrop.dart';

/// Driverless `integer`/`text` column shorthands for test schemas.
extension TestColumnDefinitions<R> on SchemaBuilder<R> {
  /// An [int] column, stored as an INTEGER, optionally with a
  /// [defaultValue].
  ColumnType<W> integer<W extends int?>(
    String name,
    Field<R, W> field, {
    ColumnOr<int>? defaultValue,
  }) {
    return column<int, W>(
      name,
      field,
      sqlType: 'INTEGER',
      defaultValue: defaultValue,
    );
  }

  /// A [String] column, stored as a TEXT, optionally with a [defaultValue].
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
