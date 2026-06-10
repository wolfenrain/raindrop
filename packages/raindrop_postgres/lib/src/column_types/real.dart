import 'package:raindrop/raindrop.dart';

extension RealColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> real<W extends double?>(String name, Field<R, W> field) {
    return column<double, W>(name, field, sqlType: 'REAL');
  }
}
