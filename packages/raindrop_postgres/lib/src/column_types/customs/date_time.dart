import 'package:raindrop/raindrop.dart';

extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  T dateTime<T extends DateTimeColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return custom<DateTimeColumn, DateTime, int, W>(
      DateTimeColumn.new,
      name,
      field,
      transformer: const DateTimeTransfomer(),
      sqlType: sqlType ?? 'TIMESTAMP',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type DateTimeColumn(Column<dynamic, DateTime> _)
    implements ColumnType<DateTime> {}

class DateTimeTransfomer extends ColumnTransformer<DateTime, int> {
  const DateTimeTransfomer();

  @override
  int encode(DateTime input) => input.millisecondsSinceEpoch;

  @override
  DateTime decode(int input) => DateTime.fromMillisecondsSinceEpoch(input);
}
