import 'package:raindrop/raindrop.dart';

extension RealColumnDefinition<R> on SchemaBuilder<R> {
  T real<T extends RealColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return column<RealColumn, double, W>(
      RealColumn.new,
      name,
      field,
      sqlType: sqlType ?? 'REAL',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type RealColumn(Column<dynamic, double> _)
    implements ColumnType<double> {}
