import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(_fallbackTxBody);
  });

  late _MockConnection connection;
  late _MockTxSession txSession;
  late PostgresDelegate delegate;

  setUp(() {
    connection = _MockConnection();
    txSession = _MockTxSession();
    delegate = PostgresDelegate(connection);

    when(() => connection.runTx<int>(any())).thenAnswer((invocation) {
      final body = invocation.positionalArguments.first as Future<int> Function(
          pg.TxSession);
      return body(txSession);
    });
    when(
      () => txSession.execute(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async => _result());
  });

  group('PostgresDelegate', () {
    test('speaks the postgres dialect', () {
      expect(delegate.dialect, isA<PostgresDialect>());
    });

    group('execute', () {
      test('forwards query and parameters and translates the result', () async {
        when(
          () => connection.execute(
            r'SELECT * FROM t WHERE id = $1',
            parameters: [1],
          ),
        ).thenAnswer(
          (_) async => _result(
            columns: ['id', 'name'],
            rows: [
              [1, 'a'],
              [2, 'b'],
            ],
            affectedRows: 2,
          ),
        );

        final result = await delegate.execute(
          r'SELECT * FROM t WHERE id = $1',
          [1],
        );

        expect(result.columns, ['id', 'name']);
        expect(result.rows, [
          [1, 'a'],
          [2, 'b'],
        ]);
        expect(result.rowsAffected, 2);
        expect(result.lastInsertedRowId, isNull);
      });

      test('a row-less result translates to empty columns and rows', () async {
        when(
          () => connection.execute('DELETE FROM t', parameters: []),
        ).thenAnswer((_) async => _result(affectedRows: 3));

        final result = await delegate.execute('DELETE FROM t', []);

        expect(result.columns, isEmpty);
        expect(result.rows, isEmpty);
        expect(result.rowsAffected, 3);
      });
    });

    group('transaction', () {
      test('runs the body against the transaction session', () async {
        final value = await delegate.transaction((tx) async {
          expect(tx.dialect, isA<PostgresDialect>());
          expect(tx.depth, 0);
          await tx.execute('INSERT INTO t VALUES (1)', [7]);
          return 42;
        });

        expect(value, 42);
        verify(
          () => txSession.execute(
            'INSERT INTO t VALUES (1)',
            parameters: [7],
          ),
        ).called(1);
      });

      test('a nested transaction wraps its body in a savepoint', () async {
        await delegate.transaction((tx) async {
          return tx.transaction((inner) async {
            expect(inner.depth, 1);
            await inner.execute('INSERT INTO t VALUES (2)', []);
            return 0;
          });
        });

        verifyInOrder([
          () => txSession.execute('SAVEPOINT sp_0', parameters: []),
          () => txSession.execute(
                'INSERT INTO t VALUES (2)',
                parameters: [],
              ),
          () => txSession.execute('RELEASE SAVEPOINT sp_0', parameters: []),
        ]);
      });

      test('deeper nesting numbers its savepoints by depth', () async {
        await delegate.transaction((tx) async {
          return tx.transaction((inner) async {
            return inner.transaction((innermost) async {
              expect(innermost.depth, 2);
              return 0;
            });
          });
        });

        verifyInOrder([
          () => txSession.execute('SAVEPOINT sp_0', parameters: []),
          () => txSession.execute('SAVEPOINT sp_1', parameters: []),
          () => txSession.execute('RELEASE SAVEPOINT sp_1', parameters: []),
          () => txSession.execute('RELEASE SAVEPOINT sp_0', parameters: []),
        ]);
      });

      test('a failing nested transaction rolls back to its savepoint',
          () async {
        await expectLater(
          delegate.transaction((tx) async {
            return tx.transaction<int>((inner) async {
              throw StateError('abort');
            });
          }),
          throwsStateError,
        );

        verify(
          () => txSession.execute('ROLLBACK TO sp_0', parameters: []),
        ).called(1);
        verifyNever(
          () => txSession.execute('RELEASE SAVEPOINT sp_0', parameters: []),
        );
      });

      test('rollback aborts via TransactionRollback', () async {
        await expectLater(
          delegate.transaction<int>((tx) async {
            await tx.rollback();
            return 0;
          }),
          throwsA(isA<TransactionRollback>()),
        );
      });
    });
  });
}

class _MockConnection extends Mock implements pg.Connection {}

class _MockTxSession extends Mock implements pg.TxSession {}

/// Builds a real postgres [pg.Result], the concrete value a session returns.
pg.Result _result({
  List<String> columns = const [],
  List<List<Object?>> rows = const [],
  int affectedRows = 0,
}) {
  final schema = pg.ResultSchema([
    for (final name in columns)
      pg.ResultSchemaColumn(
        typeOid: pg.Type.text.oid!,
        type: pg.Type.text,
        columnName: name,
      ),
  ]);
  return pg.Result(
    rows: [
      for (final row in rows) pg.ResultRow(schema: schema, values: row),
    ],
    affectedRows: affectedRows,
    schema: schema,
  );
}

Future<int> _fallbackTxBody(pg.TxSession session) async => 0;
