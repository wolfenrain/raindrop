import 'package:raindrop/raindrop.dart';

extension FloatColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  FloatColumn float(
    String name,
    double Function(S) valueOf, {
    required double value,
  }) {
    return column(FloatColumn.new, valueOf, name: name, value: value);
  }
}

extension type FloatColumn(double _) implements ColumnType<double>, double {}
