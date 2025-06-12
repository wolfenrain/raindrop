part of 'delegates.dart';

/// {@template delegate}
/// Abstract delegate class that provides all the necessary components to talk
/// to a [SqlDialect].
/// {@endtemplate}
abstract class Delegate {
  /// {@macro delegate}
  const Delegate(this.dialect);

  /// The dialect used by the delegate.
  final SqlDialect dialect;

  /// Execute a [query] with it's [values] inside the database to which this
  /// [Delegate] is connected.
  Future<List<Map<String, dynamic>>> execute(
    String query,
    List<Object?> values,
  );

  /// Perform a transaction on the database.
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  );

  /// Create an insert builder for an entity.
  InsertValuesBuilder<S, void> insert<S extends Schema<S>>(
    RaindropExecutor executor,
    Table<S> into,
  ) {
    return InsertValuesBuilder(
      executor,
      config: QueryConfig.from({#into: into}),
    );
  }

  /// Create a select builder for an entity.
  SelectBuilder<V> select<V>(
    RaindropExecutor executor,
    Selectable<V>? selecting,
  ) {
    return SelectBuilder(
      executor,
      config: QueryConfig.from({#selecting: selecting}),
    );
  }

  /// Create an update builder for an entity.
  UpdateSettingBuilder<S, void> update<S extends Schema<S>>(
    RaindropExecutor executor,
    Table<S> table,
  ) {
    return UpdateSettingBuilder(
      executor,
      config: QueryConfig.from({#table: table}),
    );
  }

  /// Create a delete builder for an entity.
  DeleteAllBuilder<S, void> delete<S extends Schema<S>>(
    RaindropExecutor executor,
    Table<S> from,
  ) {
    return DeleteAllBuilder(
      executor,
      config: QueryConfig.from({#from: from}),
    );
  }
}
