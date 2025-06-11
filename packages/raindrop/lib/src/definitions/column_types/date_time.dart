import 'package:raindrop/raindrop.dart';

extension DateTimeColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  DateTimeColumn dateTime(
    String name,
    DateTime Function(S) valueOf, {
    required DateTime value,
  }) {
    return column(DateTimeColumn.new, valueOf, name: name, value: value);
  }
}

extension type DateTimeColumn(DateTime _)
    implements ColumnType<DateTime>, DateTime {}
