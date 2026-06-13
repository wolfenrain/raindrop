import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  group('SQLiteDelegate.execute', () {
    late Database database;
    late SQLiteDelegate delegate;

    setUp(() {
      database = sqlite3.openInMemory();
      delegate = SQLiteDelegate(database);
    });

    tearDown(() {
      database.dispose();
    });

    test('read-only statement reports no rows affected or last insert id',
        () async {
      final result = await delegate.execute('SELECT 1 AS n', const []);
      expect(result.columns, ['n']);
      expect(result.rows, [
        [1],
      ]);
      expect(result.rowsAffected, 0);
      expect(result.lastInsertedRowId, isNull);
    });

    test('INSERT reports rows affected and lastInsertedRowId', () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY AUTOINCREMENT, x TEXT)',
        const [],
      );

      final result =
          await delegate.execute("INSERT INTO t (x) VALUES (?)", ['hello']);

      expect(result.rowsAffected, 1);
      expect(result.lastInsertedRowId, 1);
      expect(result.rows, isEmpty);
    });

    test('UPDATE reports rows affected', () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        const [],
      );
      await delegate.execute(
        'INSERT INTO t (id, x) VALUES (1, ?)',
        ['a'],
      );

      final result =
          await delegate.execute('UPDATE t SET x = ? WHERE id = 1', ['b']);

      expect(result.rowsAffected, 1);
      // `lastInsertRowId` is connection state; it stays set after a prior INSERT.
      expect(result.lastInsertedRowId, 1);
    });

    test('UPDATE with no prior INSERT leaves lastInsertedRowId unset',
        () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        const [],
      );

      final result =
          await delegate.execute('UPDATE t SET x = ? WHERE id = 99', ['z']);

      expect(result.rowsAffected, 0);
      expect(result.lastInsertedRowId, isNull);
    });

    test('DELETE reports rows affected', () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        const [],
      );
      await delegate.execute(
        'INSERT INTO t (id, x) VALUES (1, ?)',
        ['a'],
      );

      final result = await delegate.execute('DELETE FROM t WHERE id = 1', []);

      expect(result.rowsAffected, 1);
      expect(result.lastInsertedRowId, 1);
    });
  });
}
