import 'package:raindrop/raindrop.dart';

/// Timestamps, stored as an INTEGER.
extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  /// A [DateTime] column, stored as milliseconds since the Unix epoch.
  ColumnType<W> dateTime<W extends DateTime?>(String name, Field<R, W> field) {
    return custom<DateTime, Object, W>(
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
class DateTimeTransformer extends ColumnTransformer<DateTime, Object> {
  /// {@macro date_time_transformer}
  const DateTimeTransformer();

  @override
  Object encode(DateTime input) => input.millisecondsSinceEpoch;

  /// Storage/wire values arrive as epoch milliseconds (int, from sqlite or a
  /// wire-conscious client) or an ISO-8601 string (the natural JSON encoding
  /// of a timestamp, from a JSON create/update body). Accepting both avoids a
  /// bare `TypeError` surfacing as a 500. `.toLocal()` keeps both forms
  /// decoding to the same representation the int path always returned.
  @override
  DateTime decode(Object input) => switch (input) {
        final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
        final String iso => (DateTime.tryParse(iso) ??
                (throw FormatException(
                  'Invalid DateTime value: "$iso" is not epoch milliseconds '
                  'or an ISO-8601 string',
                )))
            .toLocal(),
        _ => throw FormatException(
            'Invalid DateTime value: $input (${input.runtimeType})',
          ),
      };
}
