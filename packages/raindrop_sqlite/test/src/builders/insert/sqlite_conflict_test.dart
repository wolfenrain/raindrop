import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../../_support/fixtures.dart';

void main() {
  late Database database;
  late Raindrop db;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: SilentLogger());
    await db.execute(
      '''
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, "favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)''',
    );
    await db.insert(into: users).values([
      User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
    ]);
  });

  tearDown(() => database.close());

  group('onConflict', () {
    test('doNothing skips the conflicting row', () async {
      await db.insert(into: users).values([
        User(name: 'Morgan', favoriteGame: 'tetris', age: 31)
      ]).onConflict([users.name]).doNothing();

      final row = await db.select().from(users).single;
      expect(row.favoriteGame, 'zelda');
      expect(row.age, 30);
    });

    test('a bare onConflict skips any conflict', () async {
      await db
          .insert(into: users)
          .values([User(name: 'Morgan', favoriteGame: 'tetris', age: 31)])
          .onConflict()
          .doNothing();

      expect(await db.select().from(users), hasLength(1));
    });

    test('doUpdate updates the existing row', () async {
      await db.insert(into: users).values([
        User(name: 'Morgan', favoriteGame: 'ignored', age: 0)
      ]).onConflict([users.name]).doUpdate(
          [users.favoriteGame.to('tetris'), users.age.to(31)]);

      final row = await db.select().from(users).single;
      expect(row.favoriteGame, 'tetris');
      expect(row.age, 31);
    });

    test('doUpdate reads the failed row through excluded', () async {
      await db.insert(into: users).values([
        User(name: 'Morgan', favoriteGame: 'tetris', age: 44)
      ]).onConflict([users.name]).doUpdate([users.age.to(excluded(users.age))]);

      final row = await db.select().from(users).single;
      expect(row.favoriteGame, 'zelda');
      expect(row.age, 44);
    });

    test('doUpdate where only updates matching rows', () async {
      Future<void> offer(int age) => db.insert(into: users).values([
            User(name: 'Morgan', favoriteGame: 'zelda', age: age)
          ]).onConflict([users.name]).doUpdate(
            [users.age.to(excluded(users.age))],
            where: users.age.lessThan(excluded(users.age)),
          );

      await offer(44);
      await offer(20);

      final row = await db.select().from(users).single;
      expect(row.age, 44, reason: 'only the higher age wins');
    });

    test('doUpdate combines with returning', () async {
      final updated = await db.insert(into: users).values([
        User(name: 'Morgan', favoriteGame: 'ignored', age: 0)
      ]).onConflict([users.name]).doUpdate([users.age.to(31)]).returning();

      expect(updated.single.name, 'Morgan');
      expect(updated.single.age, 31);
    });

    test('excluded carries the column transformer', () {
      expect(excluded(users.deletedAt).transformer, isNotNull);
      expect(excluded(users.name).transformer, isNull);
    });

    test('a non-conflicting row simply inserts', () async {
      await db.insert(into: users).values([
        User(name: 'Alex', favoriteGame: 'tetris', age: 28)
      ]).onConflict([users.name]).doNothing();

      expect(await db.select().from(users), hasLength(2));
    });

    test('doUpdate and where without a target are rejected', () {
      final insert = db.insert(into: users).values(
        [User(name: 'Morgan', favoriteGame: 'zelda', age: 30)],
      );

      expect(
        () => insert.onConflict().doUpdate([users.age.to(31)]),
        throwsStateError,
      );
      expect(
        () => insert.onConflict().where(users.age.greaterThan(0)),
        throwsStateError,
      );
    });
  });
}
