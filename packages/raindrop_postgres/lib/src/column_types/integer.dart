import 'package:raindrop/raindrop.dart';

extension IntColumnDefinition<R> on SchemaBuilder<R> {
  T integer<T extends IntColumn?>(
    String name,
    Field<R, int> field,
  ) {
    return column(IntColumn.new, name, field, sqlType: 'INTEGER') as T;
  }
}

extension type IntColumn(Column<dynamic, int> _) implements ColumnType<int> {}
