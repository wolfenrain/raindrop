part of 'raindrop.dart';

/// {@template raindrop_executor}
///
/// {@endtemplate}
class RaindropExecutor<D extends Delegate> {
  /// {@macro raindrop_executor}
  RaindropExecutor(this.delegate) : _lock = Lock();

  /// The delegate of the current database.
  final D delegate;

  final Lock _lock;

  /// Execute a raw [query].
  Future<List<Map<String, dynamic>>> execute(
    String query, [
    List<Object?> values = const [],
  ]) {
    if (Zone.current[#delegate] case final Delegate d when d != delegate) {
      final error = StringBuffer();
      if (delegate is RaindropDelegate) {
        error.write('''
You can not use the main database executor inside a transaction.''');
      }
      if (delegate is TransactionDelegate) {
        error.write('''
You can not use a parent transaction executor inside a nested transaction.''');
      }
      error.write('''

This bypasses the current transaction context and could lead to inconsistent behavior.

💡 To fix this, use the transaction executor instead.''');

      throw StateError('$error');
    }

    return _lock.run(() => delegate.execute(query, values));
  }

  /// Perform a transaction on the database.
  Future<T> transaction<T>(
    Future<T> Function(RaindropExecutor<TransactionDelegate> tx) transaction,
  ) {
    return _lock.run(
      () => delegate.transaction(
        (tx) => runZoned(
          () => transaction(RaindropExecutor(tx)),
          zoneValues: {#delegate: tx},
        ),
      ),
    );
  }

  /// Create an insert builder for inserting entities [into] the database.
  InsertValuesBuilder<S, void> insert<S extends Schema<S>>({
    required S into,
  }) {
    return delegate.insert(this, Table.getForSchema<S>()!);
  }

  /// Create a select builder that can filter down on [selectable] if needed.
  SelectBuilder<V> select<V extends Object?>([Selectable<V>? selectable]) {
    return delegate.select(this, selectable);
  }

  /// Create an update builder that can update a [table].
  UpdateSettingBuilder<S, void> update<S extends Schema<S>>(
    S table,
  ) {
    return delegate.update(this, Table.getForSchema<S>()!);
  }

  /// Create a delete builder that can delete data [from] the database.
  DeleteAllBuilder<S, void> delete<S extends Schema<S>>({
    required S from,
  }) {
    return delegate.delete(this, Table.getForSchema<S>()!);
  }

  /// Execute the [query] on the database and return the mapped entities.
  Future<List<V>> query<S extends Schema<S>, V>(
    Query<S, V> queryOrBuilder,
  ) async {
    var query = queryOrBuilder;
    if (query case final ToQuery<S, V> builder) {
      query = builder.toQuery();
    }

    return Raindrop.tracer.trace('RaindropExecutor.query', (span) async {
      span?.attributes.addAll({'query': '${query.runtimeType}'});
      final registry = AliasRegistry(query);
      final (sql, values) = delegate.dialect.translate(query, registry);
      final data = await execute(sql, values);

      return data
          .map((value) {
            if (query case final Select<S, V> select) {
              return Selectable.read(select.selecting, value, registry);
            } else if (query case final Insert<S, V> insert) {
              return insert.into.create(value);
            } else if (query case final Update<S, V> update) {
              return Updateable.read<S, V>(update.set, value, registry);
            } else if (query case final Delete<S, V> delete) {
              return delete.from.create(value);
            }

            return null;
          })
          .cast<V>()
          .toList();
    });
  }

  /// Return the first result of the [query].
  ///
  /// Note: if the query returns multiple rows they will be read and then
  /// discarded, keep that in mind when writing your query.
  Future<V?> queryOne<S extends Schema<S>, V>(Query<S, V> query) async {
    return (await this.query(query)).firstOrNull;
  }
}
