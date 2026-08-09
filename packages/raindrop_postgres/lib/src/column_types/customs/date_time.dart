import 'package:raindrop/raindrop.dart';

/// [DateTime] columns that are stored as SQL based values.
extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  /// A [DateTime] column over `TIMESTAMP`.
  ColumnType<W> dateTime<W extends DateTime?>(String name, Field<R, W> field) {
    return column<DateTime, W>(name, field, sqlType: 'TIMESTAMP');
  }
}
