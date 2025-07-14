import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteUpdateReturningBuilder<S extends Schema<S>, V, R>
    extends UpdateWhereBuilder<S, V, R> {
  SQLiteUpdateReturningBuilder(super.executor, {required super.config});

  @override
  Update<S, R> toQuery() {
    return SQLiteUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}
