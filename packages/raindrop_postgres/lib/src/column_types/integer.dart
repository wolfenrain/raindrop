import 'package:raindrop/raindrop.dart';

/// [int] columns that are stored as integer values.
extension IntColumnDefinition<R> on SchemaBuilder<R> {
  /// An [int] column over `INTEGER`.
  ColumnType<W> integer<W extends int?>(String name, Field<R, W> field) {
    return column<int, W>(name, field, sqlType: 'INTEGER');
  }
}
