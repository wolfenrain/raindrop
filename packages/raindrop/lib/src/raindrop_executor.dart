part of 'raindrop.dart';

/// {@template raindrop_executor}
///
/// {@endtemplate}
class RaindropExecutor<D extends Delegate> {
  /// {@macro raindrop_executor}
  RaindropExecutor(
    this.delegate, {
    required Logger logger,
  })  : _log = logger,
        _lock = Lock();

  /// The delegate of the current database.
  final D delegate;

  final Logger _log;

  final Lock _lock;

  /// Execute a raw [query].
  Future<DatabaseResult> execute(
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

    return _lock.run(() {
      _log.query(query, values);
      return delegate.execute(query, values);
    });
  }

  /// Perform a transaction on the database.
  Future<T> transaction<T>(
    Future<T> Function(RaindropExecutor<TransactionDelegate> tx) transaction,
  ) {
    return _lock.run(
      () => delegate.transaction(
        (tx) => runZoned(
          () => transaction(RaindropExecutor(tx, logger: _log)),
          zoneValues: {#delegate: tx},
        ),
      ),
    );
  }

  /// Create an insert builder for inserting entities [into] the database.
  InsertValuesBuilder<S, void> insert<S extends Schema<S>>({
    required S into,
  }) {
    return delegate.insert(this, Table.get(into)! as Table<S>);
  }

  /// Create a select builder that can filter down on [selectable] if needed.
  SelectBuilder<V> select<V extends Object?>([
    Selectable<V>? selectable,
  ]) {
    return delegate.select(this, selectable);
  }

  /// Create an update builder that can update a [table].
  UpdateSettingBuilder<S, void> update<S extends Schema<S>>(
    S table,
  ) {
    return delegate.update(this, Table.get(table)! as Table<S>);
  }

  /// Create a delete builder that can delete data [from] the database.
  DeleteAllBuilder<S, void> delete<S extends Schema<S>>({
    required S from,
  }) {
    return delegate.delete(this, Table.get(from)! as Table<S>);
  }

  /// Execute the [queryOrBuilder] on the database and return the mapped
  /// entities.
  Future<List<V>> query<S extends Schema<S>, V>(Query<S, V> queryOrBuilder) {
    final query = switch (queryOrBuilder) {
      ToQuery() => queryOrBuilder.toQuery(),
      _ => queryOrBuilder,
    };

    return Raindrop.tracer.trace('RaindropExecutor.query', (span) async {
      span?.attributes.addAll({'query': '${query.runtimeType}'});
      final (sql, values) = delegate.dialect.translate(query);
      final result = await execute(sql, values);

      final records = switch (query) {
        Insert() => result.rows.map((e) => _read(query.into, [...e])),
        Select() => result.rows.map((e) => _read(query.selecting, [...e])),
        Update() => result.rows.map((e) => _read(query.set.toReadable, [...e])),
        Delete() => result.rows.map((e) => _read(query.from, [...e])),
        _ => throw UnimplementedError('${query.runtimeType}'),
      };

      return records.cast<V>().toList();
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

R _read<R>(Selectable<R> selectable, List<Object?> rows) {
  if (selectable case final Schema schema) {
    return _read(Table.get(schema)!, rows) as R;
  }

  if (selectable case final Table table) {
    final data = <String, dynamic>{
      for (final column in table.columns) column.name: _read(column, rows),
    };

    return switch (data.values.whereType<Object>().isEmpty) {
      // TODO: this could fail if a schema is fully nullable?
      true => null,
      _ => table.create(data)
    } as R;
  } else if (selectable case final Column column) {
    final value = rows.removeAt(0);
    if (column is ColumnTransform) {
      return value as R;
    }
    return column.decode(value) as R;
  } else if (selectable case final SelectableResult result) {
    return result.readRecord(rows) as R;
  } else {
    throw UnimplementedError('${selectable.runtimeType}');
  }
}

extension<R> on SelectableResult<R> {
  R readRecord(List<Object?> rows) {
    switch (selected.length) {
      case 2:
        return (
          _read(selected[0], rows),
          _read(selected[1], rows),
        ) as R;
      case 3:
        return (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
        ) as R;
      default:
        throw UnsupportedError('${selected.length}');
    }
  }
}

extension<R> on Updateable<R> {
  Selectable<R> get toReadable {
    if (this case final UpdateableTable update) {
      return update.table as Selectable<R>;
    } else if (this case final UpdateableColumn update) {
      return update.column as Selectable<R>;
    } else if (this case final UpdateableResult<dynamic> result) {
      return SelectableResult(
        result.updating.map((u) => u.toReadable).toList(),
      );
    }

    throw 'Unsupported $this';
  }
}
