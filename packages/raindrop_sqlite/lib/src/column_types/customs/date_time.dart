import 'package:raindrop/raindrop.dart';

extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> dateTime<W extends DateTime?>(String name, Field<R, W> field) {
    return custom<DateTime, int, W>(
      name,
      field,
      transformer: const DateTimeTransformer(),
      sqlType: 'INTEGER',
    );
  }
}

class DateTimeTransformer extends ColumnTransformer<DateTime, int> {
  const DateTimeTransformer();

  @override
  int encode(DateTime input) => input.millisecondsSinceEpoch;

  @override
  DateTime decode(int input) => DateTime.fromMillisecondsSinceEpoch(input);
}
