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

  /// Render [query] to SQL, execute it, and decode the returned rows.
  Future<List<V>> run<V>(Query<V> query) {
    return Raindrop.tracer.trace('RaindropExecutor.run', (span) async {
      final (sql, values) = delegate.dialect.translate(query);
      span?.attributes.addAll({'sql': sql, 'values': values});
      final result = await execute(sql, values);
      return result.rows
          .map((e) => _read(query.shape, [...e]))
          .cast<V>()
          .toList();
    });
  }
}

R _read<R>(Selectable<R> selectable, List<Object?> rows) {
  if (selectable case final Schema schema) {
    return _read(Table.get(schema)!, rows) as R;
  }

  if (selectable case final Table table) {
    final data = <String, dynamic>{
      for (final column in table.columns) column.name: rows.removeAt(0),
    };

    return switch (data.values.whereType<Object>().isEmpty) {
      // TODO: this could fail if a schema is fully nullable?
      true => null,
      _ => table.create(data)
    } as R;
  } else if (selectable case final SqlOperand operand) {
    final value = rows.removeAt(0);
    return operand.decode(value) as R;
  } else if (selectable case final SelectableResult result) {
    return result.readRecord(rows) as R;
  } else {
    throw UnimplementedError('${selectable.runtimeType}');
  }
}

// TODO(wolfen): generate this??
extension<R> on SelectableResult<R> {
  R readRecord(List<Object?> rows) {
    return switch (selected.length) {
      2 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
        ) as R,
      3 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
        ) as R,
      4 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
          _read(selected[3], rows),
        ) as R,
      5 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
          _read(selected[3], rows),
          _read(selected[4], rows),
        ) as R,
      6 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
          _read(selected[3], rows),
          _read(selected[4], rows),
          _read(selected[5], rows),
        ) as R,
      7 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
          _read(selected[3], rows),
          _read(selected[4], rows),
          _read(selected[5], rows),
          _read(selected[6], rows),
        ) as R,
      8 => (
          _read(selected[0], rows),
          _read(selected[1], rows),
          _read(selected[2], rows),
          _read(selected[3], rows),
          _read(selected[4], rows),
          _read(selected[5], rows),
          _read(selected[6], rows),
          _read(selected[7], rows),
        ) as R,
      _ => throw UnsupportedError('${selected.length}'),
    };
  }
}
