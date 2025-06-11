import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class SQLiteInsertValuesBuilder<S extends Schema<S>, V>
    extends InsertValuesBuilder<S, V> {
  SQLiteInsertValuesBuilder(super.executor, {required super.config});

  // TODO: only on non inserted builder!
  @override
  InsertWithValuesBuilder<S, V> values(List<S> values) {
    return SQLiteInsertWithValuesBuilder(
      executor,
      config: config.copyWith({
        #values: [...values],
      }),
    );
  }
}

class SQLiteInsertWithValuesBuilder<S extends Schema<S>, V>
    extends InsertWithValuesBuilder<S, V> {
  SQLiteInsertWithValuesBuilder(
    super.executor, {
    required super.config,
  });

  @override
  Insert<S, V> toQuery() {
    return SQLiteInsert(
      into: config.get(#into)!,
      values: config.get(#values)!,
      withReturning: config.get(#withReturning) ?? false,
    );
  }
}

extension SQLiteInsertReturningExtension<S extends Schema<S>>
    on InsertWithValuesBuilder<S, void> {
  SQLiteInsertReturningBuilder<S, S> returning() {
    return SQLiteInsertReturningBuilder<S, S>(
      executor,
      config: config.copyWith({
        #withReturning: true,
      }),
    );
  }
}
