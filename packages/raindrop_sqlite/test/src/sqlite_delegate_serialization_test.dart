import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  group('SQLiteDelegate serialization', () {
    late Database database;
    late SQLiteDelegate delegate;

    setUp(() async {
      database = sqlite3.openInMemory();
      delegate = SQLiteDelegate(database);
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        [],
      );
    });

    tearDown(() => database.close());

    int rowCount() =>
        database.select('SELECT count(*) AS n FROM t').first['n']! as int;

    test('concurrent transactions on one connection all succeed', () async {
      Future<void> runTransaction(int i) => delegate.transaction((tx) async {
            await tx.execute('SELECT * FROM t', []);
            await Future<void>.delayed(Duration.zero);
            await tx.execute('INSERT INTO t (x) VALUES (?)', ['row_$i']);
          });

      await Future.wait(List.generate(20, runTransaction));

      expect(rowCount(), 20);
    });

    test('execute() waits for an in-flight transaction', () async {
      final transaction = delegate.transaction((tx) async {
        await Future<void>.delayed(Duration.zero);
        await tx.execute('INSERT INTO t (x) VALUES (?)', ['a']);
      });
      final count = delegate.execute('SELECT count(*) AS n FROM t', []);

      await transaction;
      expect((await count).rows.single.single, 1);
    });

    test('a failing transaction does not block later calls', () async {
      await expectLater(
        delegate.transaction((tx) async => throw StateError('abort')),
        throwsStateError,
      );

      final result = await delegate.execute('SELECT 1 AS n', []);
      expect(result.rows.single.single, 1);
    });

    test('execute() on the delegate inside its own transaction fails',
        () async {
      await expectLater(
        delegate.transaction((tx) async {
          await tx.execute('INSERT INTO t (x) VALUES (?)', ['a']);
          await delegate.execute('SELECT 1', []);
        }),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('must use the TransactionDelegate'),
          ),
        ),
      );

      expect(rowCount(), 0, reason: 'the transaction rolled back');
    });

    test('transaction() on the delegate inside its own transaction fails',
        () async {
      await expectLater(
        delegate.transaction((tx) async {
          await delegate.transaction((inner) async {});
        }),
        throwsStateError,
      );
    });
  });
}
