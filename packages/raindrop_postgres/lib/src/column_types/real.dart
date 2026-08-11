import 'package:raindrop/raindrop.dart';

/// [double] columns that are stored as floating-point values.
extension RealColumnDefinition<R> on SchemaBuilder<R> {
  /// A [double] column over `REAL`.
  ColumnType<W> real<W extends double?>(String name, Field<R, W> field) {
    return column<double, W>(name, field, sqlType: 'REAL');
  }
}
