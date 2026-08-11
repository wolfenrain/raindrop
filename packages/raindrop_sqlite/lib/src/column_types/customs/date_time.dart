import 'package:raindrop/raindrop.dart';

/// Timestamps, stored as an INTEGER.
extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  /// A [DateTime] column, stored as milliseconds since the Unix epoch.
  ColumnType<W> dateTime<W extends DateTime?>(String name, Field<R, W> field) {
    return custom<DateTime, int, W>(
      name,
      field,
      transformer: const DateTimeTransformer(),
      sqlType: 'INTEGER',
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
