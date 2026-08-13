import 'package:raindrop/raindrop.dart';

/// [DateTime] columns that are stored as SQL based values.
extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  /// A [DateTime] column over `TIMESTAMP`.
  ///
  /// [defaultValue] is a [DateTime] like any other value for this column,
  /// rather than a raw SQL string, so it cannot disagree with the column type.
  ColumnType<W> dateTime<W extends DateTime?>(
    String name,
    Field<R, W> field, {
    ColumnOr<DateTime>? defaultValue,
  }) {
    return column<DateTime, W>(
      name,
      field,
      sqlType: 'TIMESTAMP',
      defaultValue: defaultValue,
    );
  }
}
