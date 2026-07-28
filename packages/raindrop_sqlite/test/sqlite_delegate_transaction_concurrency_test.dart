import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  group('SQLiteDelegate.transaction concurrency', () {
    late Database database;
    late SQLiteDelegate delegate;

    setUp(() {
      database = sqlite3.openInMemory();
      delegate = SQLiteDelegate(database);
    });

    tearDown(() {
      database.dispose();
    });

    test(
      'concurrent transactions on one connection all succeed instead of '
      'racing on BEGIN',
      () async {
        await delegate.execute(
          'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
          const [],
        );

        Future<void> runTransaction(int i) => delegate.transaction((
              tx,
            ) async {
              await tx.execute('SELECT * FROM t', const []);
              await Future<void>.delayed(Duration.zero);
              await tx.execute('INSERT INTO t (x) VALUES (?)', ['row_$i']);
            });

        await Future.wait(List.generate(20, runTransaction));

        final result =
            await delegate.execute('SELECT COUNT(*) AS n FROM t', const []);
        expect(result.rows.single.single, 20);
      },
    );

    test(
      'a plain execute() call is serialized against an in-flight transaction',
      () async {
        await delegate.execute(
          'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
          const [],
        );

        final futures = <Future<void>>[
          delegate.transaction((tx) async {
            await Future<void>.delayed(Duration.zero);
            await tx.execute('INSERT INTO t (x) VALUES (?)', ['a']);
          }),
          delegate.execute('SELECT * FROM t', const []).then((_) {}),
        ];

        await Future.wait(futures);
      },
    );
  });
}
