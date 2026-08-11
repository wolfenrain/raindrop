import 'dart:async';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/src/test_dialect.dart';

/// A statement observed by a [TestDelegate], in execution order.
typedef ExecutedStatement = ({String sql, List<Object?> values});

/// Produces the [DatabaseResult] for a statement a [TestDelegate] receives.
typedef OnExecute = FutureOr<DatabaseResult> Function(
  String sql,
  List<Object?> values,
);

/// {@template test_delegate}
/// A [RaindropDelegate] that talks to no database.
///
/// Every executed statement is recorded in [statements], so a test can
/// assert on the SQL a piece of code issued. Results come from, in order of
/// precedence: the [onExecute] callback, results queued with [enqueue]
/// (FIFO), or [empty].
///
/// Transactions run their body against a [TestTransactionDelegate] that
/// shares this delegate's log and result queue. The transaction lifecycle is
/// recorded as `BEGIN`/`COMMIT`/`ROLLBACK` (and savepoint) entries in
/// [statements], even though a real driver would not route those through
/// `execute`, so tests can assert on transaction behavior.
/// {@endtemplate}
class TestDelegate extends RaindropDelegate {
  /// {@macro test_delegate}
  TestDelegate({super.dialect = const TestDialect(), this.onExecute});

  /// The result every statement gets when nothing else supplies one.
  static const empty = DatabaseResult(
    columns: [],
    rows: [],
    rowsAffected: 0,
    lastInsertedRowId: null,
  );

  /// Called for every executed statement to produce its result.
  final OnExecute? onExecute;

  /// Every statement executed against this delegate, oldest first.
  final List<ExecutedStatement> statements = [];

  final List<DatabaseResult> _results = [];

  /// Queues [result] to be returned for the next unanswered statement.
  void enqueue(DatabaseResult result) => _results.add(result);

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) async {
    statements.add((sql: query, values: List<Object?>.of(values)));
    if (onExecute case final onExecute?) return onExecute(query, values);
    if (_results.isNotEmpty) return _results.removeAt(0);
    return empty;
  }

  void _log(String sql) => statements.add((sql: sql, values: const []));

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final tx = TestTransactionDelegate._(this);
    _log('BEGIN');

    try {
      final result = await transaction(tx);
      _log('COMMIT');
      return result;
    } catch (_) {
      _log('ROLLBACK');
      rethrow;
    }
  }
}

/// {@template test_transaction_delegate}
/// The [TransactionDelegate] a [TestDelegate] hands to transaction bodies.
///
/// Shares the root delegate's statement log and result queue, nested
/// transactions record savepoint entries mirroring how drivers implement
/// them.
/// {@endtemplate}
class TestTransactionDelegate extends TransactionDelegate {
  TestTransactionDelegate._(this._root, [int depth = 0])
      : super(_root.dialect, depth);

  final TestDelegate _root;

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) =>
      _root.execute(query, values);

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    final savePoint = 'sp_$depth';
    final tx = TestTransactionDelegate._(_root, depth + 1);
    _root._log('SAVEPOINT $savePoint');

    try {
      final result = await transaction(tx);
      _root._log('RELEASE SAVEPOINT $savePoint');
      return result;
    } catch (_) {
      _root._log('ROLLBACK TO $savePoint');
      rethrow;
    }
  }

  @override
  Never rollback() => throw const TransactionRollback();
}
