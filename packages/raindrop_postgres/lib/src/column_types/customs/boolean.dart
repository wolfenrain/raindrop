import 'package:raindrop/raindrop.dart';

/// [bool] stored as SQL types.
extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  /// A [bool] column over `BOOLEAN`.
  ColumnType<W> boolean<W extends bool?>(String name, Field<R, W> field) {
    return column<bool, W>(name, field, sqlType: 'BOOLEAN');
  }
}
