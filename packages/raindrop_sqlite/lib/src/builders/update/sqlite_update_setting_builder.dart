import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteUpdateSettingBuilder<S extends Schema<R>, R, V>
    extends UpdateSettingBuilder<S, R, V> {
  SQLiteUpdateSettingBuilder(super.executor, {required super.config});
}

class SQLiteUpdateWhereBuilder<S extends Schema<R>, R, ST, V>
    extends UpdateWhereBuilder<S, R, ST, V> {
  SQLiteUpdateWhereBuilder(super.executor, {required super.config});

  @override
  Update<S, R, V> toQuery() {
    return SQLiteUpdate(
      table: config.get(#table)!,
      set: config.get(#set)!,
      where: config.get(#where),
      withReturning: config.get(#withReturning) as bool? ?? false,
      limit: config.get(#limit) as int?,
    );
  }
}

extension SQLiteUpdateReturningExtension<S extends Schema<R>, R, ST>
    on UpdateWhereBuilder<S, R, ST, void> {
  SQLiteUpdateReturningBuilder<S, R, ST, R> returning() {
    return SQLiteUpdateReturningBuilder<S, R, ST, R>(
      executor,
      config: config.copyWith({#withReturning: true}),
    );
  }
}
