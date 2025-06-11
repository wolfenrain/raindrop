import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteUpdateReturningBuilder<S extends Schema<S>, V>
    extends UpdateWhereBuilder<S, V, V> {
  SQLiteUpdateReturningBuilder(super.executor, {required super.config});

  @override
  Update<S, V> toQuery() {
    return SQLiteUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: true,
    );
  }
}
