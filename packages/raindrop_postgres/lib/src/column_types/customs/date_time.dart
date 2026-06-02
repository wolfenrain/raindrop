import 'package:raindrop/raindrop.dart';

extension DateTimeColumnDefinition<R> on SchemaBuilder<R> {
  T dateTime<T extends DateTimeColumn?>(
    String name,
    Field<R, DateTime> field,
  ) {
    return custom(
      DateTimeColumn.new,
      name,
      field,
      transformer: const DateTimeTransfomer(),
      sqlType: 'TIMESTAMP',
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
