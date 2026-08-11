import 'package:raindrop/raindrop.dart';

/// Whole numbers, stored as an INTEGER.
extension IntColumnDefinition<R> on SchemaBuilder<R> {
  /// An [int] column, optionally with a [defaultValue].
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
}
