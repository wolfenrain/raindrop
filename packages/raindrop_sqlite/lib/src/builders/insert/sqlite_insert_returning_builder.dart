import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteInsertReturningBuilder<S extends Schema<S>, V>
    extends SQLiteInsertWithValuesBuilder<S, V> {
  SQLiteInsertReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, V> toQuery() {
    return SQLiteInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning)!,
    );
  }
}
