import 'package:raindrop/raindrop.dart';

extension DateTimeColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T dateTime<T extends DateTimeColumn?>(
    String name,
    Field<S, DateTime> field,
    DateTime? value,
  ) {
    return transform<DateTime, int>(
      DateTimeColumn.new,
      name,
      field,
      value,
      transformer: const DateTimeTransfomer(),
    ) as T;
  }
}

extension type DateTimeColumn(DateTime _)
    implements ColumnType<DateTime>, DateTime {}

class DateTimeTransfomer extends ColumnTransformer<DateTime, int> {
  const DateTimeTransfomer();

  @override
  int encode(DateTime input) => input.millisecondsSinceEpoch;

  @override
  DateTime decode(int input) => DateTime.fromMillisecondsSinceEpoch(input);
}
