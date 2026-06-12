import 'package:raindrop/raindrop.dart';

extension IntColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> integer<W extends int?>(String name, Field<R, W> field) {
    return column<int, W>(name, field, sqlType: 'INTEGER');
  }
}
