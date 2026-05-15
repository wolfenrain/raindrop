import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteInsertValuesBuilder<S extends Schema<R>, R, V>
    extends InsertValuesBuilder<S, R, V> {
  SQLiteInsertValuesBuilder(super.executor, {required super.config});

  // TODO: only on non inserted builder!
  @override
  InsertWithValuesBuilder<S, R, V> values(List<R> values) {
    return SQLiteInsertWithValuesBuilder(
      executor,
      config: config.copyWith({
        #values: [...values],
      }),
    );
  }
}

class SQLiteInsertWithValuesBuilder<S extends Schema<R>, R, V>
    extends InsertWithValuesBuilder<S, R, V> {
  SQLiteInsertWithValuesBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, R, V> toQuery() {
    return SQLiteInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}

extension SQLiteInsertReturningExtension<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  SQLiteInsertReturningBuilder<S, R, R> returning() {
    return SQLiteInsertReturningBuilder<S, R, R>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
