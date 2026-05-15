import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteInsertReturningBuilder<S extends Schema<R>, R, V>
    extends SQLiteInsertWithValuesBuilder<S, R, V> {
  SQLiteInsertReturningBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, R, V> toQuery() {
    return SQLiteInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning)!,
    );
  }
}
