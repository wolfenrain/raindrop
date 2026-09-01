import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  group('SQLiteDelegate', () {
    late Database database;
    late Raindrop db;

    setUp(() async {
      database = sqlite3.openInMemory();
      db = Raindrop(SQLiteDelegate(database), logger: _SilentLogger());
      await db.execute(
        '''
CREATE TABLE payloads (id INTEGER PRIMARY KEY AUTOINCREMENT, big BLOB NOT NULL, data BLOB NOT NULL)''',
      );
      await db.execute(
        'CREATE TABLE kv (k TEXT PRIMARY KEY, v INTEGER NOT NULL)',
      );
    });

    tearDown(() => database.close());

    group('foreign keys', () {
      int pragmaOn(Database database) =>
          database.select('PRAGMA foreign_keys').first.values.first! as int;

      test('enforcement is on by default', () {
        final fresh = sqlite3.openInMemory();
        addTearDown(fresh.close);

        expect(pragmaOn(fresh), 0, reason: 'SQLite ships with it off');
        SQLiteDelegate(fresh);
        expect(pragmaOn(fresh), 1);
      });

      test('enforceForeignKeys: false leaves the connection untouched', () {
        final fresh = sqlite3.openInMemory();
        addTearDown(fresh.close);

        SQLiteDelegate(fresh, enforceForeignKeys: false);
        expect(pragmaOn(fresh), 0);
      });
    });

    test('a transaction commits', () async {
      await db.transaction((tx) async {
        await tx.execute("INSERT INTO kv VALUES ('a', 1)", []);
        await tx.execute("INSERT INTO kv VALUES ('b', 2)", []);
      });

      expect(
        database.select('SELECT count(*) AS n FROM kv').first['n'],
        2,
      );
    });

    test('a failing transaction rolls back completely', () async {
      await expectLater(
        db.transaction((tx) async {
          await tx.execute("INSERT INTO kv VALUES ('a', 1)", []);
          throw StateError('abort');
        }),
        throwsStateError,
      );

      expect(
        database.select('SELECT count(*) AS n FROM kv').first['n'],
        0,
      );
    });

    test('a nested transaction is a savepoint: inner rollback, outer commit',
        () async {
      await db.transaction((tx) async {
        await tx.execute("INSERT INTO kv VALUES ('outer', 1)", []);
        await expectLater(
          tx.transaction((inner) async {
            await inner.execute("INSERT INTO kv VALUES ('inner', 2)", []);
            throw StateError('abort inner');
          }),
          throwsStateError,
        );
      });

      final keys = database.select('SELECT k FROM kv');
      expect(keys.map((r) => r['k']), ['outer']);
    });

    test('a nested transaction that succeeds releases its savepoint', () async {
      await db.transaction((tx) async {
        await tx.execute('INSERT INTO kv (k, v) VALUES (?, ?)', ['outer', 1]);
        await tx.transaction((inner) async {
          await inner
              .execute('INSERT INTO kv (k, v) VALUES (?, ?)', ['inner', 2]);
        });
      });

      final result = await db.execute('SELECT k FROM kv ORDER BY k');
      expect(result.rows.map((r) => r.first), ['inner', 'outer']);
    });

    test('delegate.rollback() aborts via TransactionRollback', () async {
      await expectLater(
        db.transaction((tx) async {
          await tx.execute("INSERT INTO kv VALUES ('gone', 1)", []);
          await tx.delegate.rollback();
        }),
        throwsA(isA<TransactionRollback>()),
      );

      expect(
        database.select('SELECT count(*) AS n FROM kv').first['n'],
        0,
      );
    });

    test('bigInt round-trips zero and negatives', () async {
      final values = [
        BigInt.zero,
        BigInt.from(-1),
        BigInt.parse('-340282366920938463463374607431768211456'),
      ];
      await db.insert(into: _payloads).values([
        for (final value in values)
          _Payload(big: value, data: Uint8List.fromList([0])),
      ]);

      final stored = await db.select(_payloads.big).from(_payloads);
      expect(stored, values);
    });
  });

  group('SQLiteDelegate.execute', () {
    late Database database;
    late SQLiteDelegate delegate;

    setUp(() {
      database = sqlite3.openInMemory();
      delegate = SQLiteDelegate(database);
    });

    tearDown(() {
      database.close();
    });

    test('read-only statement reports no rows affected or last insert id',
        () async {
      final result = await delegate.execute('SELECT 1 AS n', []);
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
        [],
      );

      final result =
          await delegate.execute('INSERT INTO t (x) VALUES (?)', ['hello']);

      expect(result.rowsAffected, 1);
      expect(result.lastInsertedRowId, 1);
      expect(result.rows, isEmpty);
    });

    test('UPDATE reports rows affected', () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        [],
      );
      await delegate.execute(
        'INSERT INTO t (id, x) VALUES (1, ?)',
        ['a'],
      );

      final result =
          await delegate.execute('UPDATE t SET x = ? WHERE id = 1', ['b']);

      expect(result.rowsAffected, 1);
      expect(result.lastInsertedRowId, 1);
    });

    test('UPDATE with no prior INSERT leaves lastInsertedRowId unset',
        () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        [],
      );

      final result =
          await delegate.execute('UPDATE t SET x = ? WHERE id = 99', ['z']);

      expect(result.rowsAffected, 0);
      expect(result.lastInsertedRowId, isNull);
    });

    test('DELETE reports rows affected', () async {
      await delegate.execute(
        'CREATE TABLE t (id INTEGER PRIMARY KEY, x TEXT)',
        [],
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

class _Payload {
  _Payload({required this.big, required this.data, this.id});
  final int? id;
  final BigInt big;
  final Uint8List data;
}

class _PayloadSchema extends Schema<_Payload> {
  _PayloadSchema(super.$)
      : id = $.integer('id', (x) => x.id).primaryKey(autoIncrement: true),
        big = $.bigInt('big', (x) => x.big),
        data = $.blob('data', (x) => x.data);

  final ColumnType<int?> id;
  final ColumnType<BigInt> big;
  final ColumnType<Uint8List> data;

  @override
  _Payload fromRow(RowReader read) =>
      _Payload(id: read(id), big: read(big)!, data: read(data)!);
}

final _PayloadSchema _payloads = sqliteTable('payloads', _PayloadSchema.new);

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
