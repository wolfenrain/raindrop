import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/conformance.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  group('TestDelegate', () {
    test('exposes migration storage over the test generator', () {
      expect(TestDelegate().migrationStorage, isA<DdlMigrationStorage>());
    });

    test('records every executed statement with its values', () async {
      final delegate = TestDelegate();

      await delegate.execute('SELECT 1', []);
      await delegate.execute('SELECT ?', [42]);

      expect(delegate.statements.map((s) => s.sql), ['SELECT 1', 'SELECT ?']);
      expect(delegate.statements.first.values, isEmpty);
      expect(delegate.statements.last.values, [42]);
    });

    test('returns the empty result by default', () async {
      final result = await TestDelegate().execute('SELECT 1', []);

      expect(result.rows, isEmpty);
      expect(result.rowsAffected, 0);
      expect(result.lastInsertedRowId, isNull);
    });

    test('returns enqueued results in order, then falls back to empty',
        () async {
      final delegate = TestDelegate()
        ..enqueue(
          DatabaseResult(
            columns: ['a'],
            rows: [
              [1],
            ],
            rowsAffected: 0,
            lastInsertedRowId: null,
          ),
        )
        ..enqueue(
          DatabaseResult(
            columns: ['a'],
            rows: [
              [2],
            ],
            rowsAffected: 0,
            lastInsertedRowId: null,
          ),
        );

      expect((await delegate.execute('SELECT 1', [])).rows, [
        [1],
      ]);
      expect((await delegate.execute('SELECT 1', [])).rows, [
        [2],
      ]);
      expect((await delegate.execute('SELECT 1', [])).rows, isEmpty);
    });

    test('onExecute takes precedence over the queue', () async {
      final delegate = TestDelegate(
        onExecute: (sql, values) => DatabaseResult(
          columns: ['echo'],
          rows: [
            [sql],
          ],
          rowsAffected: 0,
          lastInsertedRowId: null,
        ),
      )..enqueue(TestDelegate.empty);

      final result = await delegate.execute('SELECT 1', []);

      expect(result.rows, [
        ['SELECT 1'],
      ]);
    });

    test('decodes canned rows through a schema', () async {
      final delegate = TestDelegate()
        ..enqueue(
          DatabaseResult(
            columns: ['id', 'owner_id', 'name'],
            rows: [
              [1, 7, 'Rex'],
            ],
            rowsAffected: 0,
            lastInsertedRowId: null,
          ),
        );
      final db = Raindrop(delegate);

      final result = await db.select().from(pets);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.ownerId, 7);
      expect(result.first.name, 'Rex');
    });

    test('decodes canned user rows through the schema', () async {
      final delegate = TestDelegate()
        ..enqueue(
          DatabaseResult(
            columns: ['id', 'name', 'favoriteGame', 'age', 'nickname'],
            rows: [
              [1, 'Morgan', 'zelda', 30, null],
            ],
            rowsAffected: 0,
            lastInsertedRowId: null,
          ),
        );
      final db = Raindrop(delegate);

      final result = await db.select().from(users);

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.name, 'Morgan');
      expect(result.first.favoriteGame, 'zelda');
      expect(result.first.age, 30);
    });

    group('transaction', () {
      test('records BEGIN and COMMIT around the body', () async {
        final delegate = TestDelegate();

        await delegate.transaction((tx) => tx.execute('SELECT 1', []));

        expect(delegate.statements.map((s) => s.sql), [
          'BEGIN',
          'SELECT 1',
          'COMMIT',
        ]);
      });

      test('records ROLLBACK and rethrows when the body throws', () async {
        final delegate = TestDelegate();

        await expectLater(
          delegate.transaction((tx) async => throw StateError('boom')),
          throwsStateError,
        );
        expect(delegate.statements.map((s) => s.sql), ['BEGIN', 'ROLLBACK']);
      });

      test('nested transactions record savepoints', () async {
        final delegate = TestDelegate();

        await delegate.transaction((tx) async {
          await tx.transaction((inner) => inner.execute('SELECT 1', []));
        });

        expect(delegate.statements.map((s) => s.sql), [
          'BEGIN',
          'SAVEPOINT sp_0',
          'SELECT 1',
          'RELEASE SAVEPOINT sp_0',
          'COMMIT',
        ]);
      });

      test('a failing nested transaction rolls back to its savepoint',
          () async {
        final delegate = TestDelegate();

        await delegate.transaction((tx) async {
          try {
            await tx.transaction((inner) async => throw Exception('boom'));
          } on Exception {
            // Swallowed so the outer transaction still commits.
          }
        });

        expect(delegate.statements.map((s) => s.sql), [
          'BEGIN',
          'SAVEPOINT sp_0',
          'ROLLBACK TO sp_0',
          'COMMIT',
        ]);
      });

      test('rollback() throws TransactionRollback', () async {
        final delegate = TestDelegate();

        await expectLater(
          delegate.transaction((tx) async => tx.rollback()),
          throwsA(isA<TransactionRollback>()),
        );
        expect(delegate.statements.map((s) => s.sql), ['BEGIN', 'ROLLBACK']);
      });
    });
  });
}
