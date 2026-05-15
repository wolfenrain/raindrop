import 'package:raindrop/raindrop.dart';

extension RealColumnDefinition<R> on SchemaBuilder<R> {
  T real<T extends RealColumn?>(
    String name,
    Field<R, double> field,
  ) {
    return column(RealColumn.new, name, field, sqlType: 'REAL') as T;
  }
}

extension type RealColumn(double _) implements ColumnType<double>, double {}
