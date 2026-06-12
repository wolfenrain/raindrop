import 'package:raindrop/raindrop.dart';

extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> dateTime<W extends DateTime?>(String name, Field<R, W> field) {
    return custom<DateTime, int, W>(
      name,
      field,
      transformer: const DateTimeTransfomer(),
      sqlType: 'INTEGER',
    );
  }
}

class DateTimeTransfomer extends ColumnTransformer<DateTime, int> {
  const DateTimeTransfomer();

  @override
  int encode(DateTime input) => input.millisecondsSinceEpoch;

  @override
  DateTime decode(int input) => DateTime.fromMillisecondsSinceEpoch(input);
}
