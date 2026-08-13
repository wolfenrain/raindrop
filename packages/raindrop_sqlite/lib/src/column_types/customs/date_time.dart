import 'package:raindrop/raindrop.dart';

/// Timestamps, stored as an INTEGER.
extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  /// A [DateTime] column, stored as milliseconds since the Unix epoch.
  /// [defaultValue] is a [DateTime] like any other value for this column,
  /// not a raw SQL string -- it is encoded through [DateTimeTransformer] the
  /// same way a written value is, so the default cannot disagree with the
  /// column's storage format.
  ColumnType<W> dateTime<W extends DateTime?>(
    String name,
    Field<R, W> field, {
    ColumnOr<DateTime>? defaultValue,
  }) {
    return custom<DateTime, int, W>(
      name,
      field,
      transformer: const DateTimeTransformer(),
      sqlType: 'INTEGER',
      defaultValue: defaultValue,
    );
  }
}

/// {@template date_time_transformer}
/// Encodes a [DateTime] as its [DateTime.millisecondsSinceEpoch] value.
/// {@endtemplate}
class DateTimeTransformer extends ColumnTransformer<DateTime, int> {
  /// {@macro date_time_transformer}
  const DateTimeTransformer();

  @override
  int encode(DateTime input) => input.millisecondsSinceEpoch;

  @override
  DateTime decode(int input) => DateTime.fromMillisecondsSinceEpoch(input);
}
