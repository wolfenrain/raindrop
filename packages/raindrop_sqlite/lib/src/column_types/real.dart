import 'package:raindrop/raindrop.dart';

/// Floating-point numbers, stored as a REAL.
extension RealColumnDefinition<R> on SchemaBuilder<R> {
  /// A [double] column, stored as an 8-byte IEEE floating point number.
  ColumnType<W> real<W extends double?>(String name, Field<R, W> field) {
    return column<double, W>(name, field, sqlType: 'REAL');
  }
}
