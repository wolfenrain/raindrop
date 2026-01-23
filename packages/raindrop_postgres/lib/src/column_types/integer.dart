import 'package:raindrop/raindrop.dart';

extension IntColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T integer<T extends IntColumn?>(
    String name,
    Field<S, int> field,
    int? value,
  ) {
    return column(IntColumn.new, name, field, value, sqlType: 'INTEGER') as T;
  }
}

extension type IntColumn(int _) implements ColumnType<int>, int {}
