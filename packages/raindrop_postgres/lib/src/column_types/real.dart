import 'package:raindrop/raindrop.dart';

extension RealColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T real<T extends RealColumn?>(
    String name,
    Field<S, double> field,
    double? value,
  ) {
    return column(RealColumn.new, name, field, value, sqlType: 'REAL') as T;
  }
}

extension type RealColumn(double _) implements ColumnType<double>, double {}
