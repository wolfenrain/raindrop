import 'package:raindrop/raindrop.dart';

extension IntColumnDefinition<R> on SchemaBuilder<R> {
  T integer<T extends IntColumn, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? defaultValue,
  }) {
    return column<IntColumn, int, W>(
      IntColumn.new,
      name,
      field,
      sqlType: 'INTEGER',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type IntColumn(Column<dynamic, int> _) implements ColumnType<int> {}
