import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'sql_generation_test.dart' show Pet, User, pets, users;

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}

void main() {
  late Database database;
  late Raindrop db;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: _SilentLogger());
    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, "favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, '
      'is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)',
    );
    await db.execute(
      'CREATE TABLE pets (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'owner_id INTEGER NOT NULL, name TEXT NOT NULL)',
    );
    await db.insert(into: users).values([
      User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
      User(name: 'Alex', favoriteGame: 'tetris', age: 28),
      User(name: 'Sam', favoriteGame: 'doom', age: 41),
    ]);
    await db.insert(into: pets).values([
      Pet(name: 'Rex', ownerId: 1),
      Pet(name: 'Milo', ownerId: 1),
      Pet(name: 'Smokey', ownerId: 2),
    ]);
  });

  tearDown(() => database.dispose());

  String sqlOf(Object builder) =>
      const SQLiteDialect().translate((builder as ToQuery).compile()).$1;

  group('an expression on the left of a comparison', () {
    // Every one of these was a compile error: the operators lived only on
    // ColumnOf, so an aggregate could be compared against but never compared.
    test('count() can be compared', () async {
      final busy = await db
          .select(pets.ownerId)
          .from(pets)
          .groupBy(pets.ownerId)
          .having(count(pets.id).greaterThan(1));

      expect(busy, [1]);
    });

    test('equals, notEquals and the ordering operators all read left-to-right',
        () {
      expect(sqlOf(db.select(pets.ownerId).from(pets).groupBy(pets.ownerId)
          .having(count(pets.id).equals(2))), contains(r'COUNT("id") = $1'));
      expect(sqlOf(db.select(pets.ownerId).from(pets).groupBy(pets.ownerId)
          .having(count(pets.id).notEquals(2))), contains(r'COUNT("id") != $1'));
      expect(sqlOf(db.select(pets.ownerId).from(pets).groupBy(pets.ownerId)
          .having(count(pets.id).lessThan(2))), contains(r'COUNT("id") < $1'));
      expect(
        sqlOf(db.select(pets.ownerId).from(pets).groupBy(pets.ownerId)
            .having(count(pets.id).greaterThanOrEqual(2))),
        contains(r'COUNT("id") >= $1'),
      );
    });

    test('a string expression compares lexicographically and likes', () {
      final sql = sqlOf(
        db.select(users.name).from(users).where(
              Coalesce(users.favoriteGame, 'none').like('%zel%'),
            ),
      );

      expect(sql, contains(r'COALESCE("favoriteGame", $1) LIKE $2'));
    });

    test('an expression can be null-checked', () {
      final sql = sqlOf(
        db.select(users.name).from(users).where(
              Coalesce(users.deletedAt, DateTime.utc(2026)).isNotNull(),
            ),
      );

      expect(sql, contains('IS NOT NULL'));
    });

    test('an expression can be tested against a list', () {
      final sql = sqlOf(
        db
            .select(pets.ownerId)
            .from(pets)
            .groupBy(pets.ownerId)
            .having(count(pets.id).inList([1, 2])),
      );

      expect(sql, contains(r'COUNT("id") IN ($1, $2)'));
    });
  });

  group('HAVING', () {
    test('sits between GROUP BY and ORDER BY', () {
      final sql = sqlOf(
        db
            .select(pets.ownerId)
            .from(pets)
            .groupBy(pets.ownerId)
            .having(count(pets.id).greaterThan(1))
            .orderBy({pets.ownerId: Order.asc}),
      );

      expect(
        sql,
        contains('GROUP BY "owner_id" HAVING COUNT("id") > \$1 ORDER BY'),
      );
    });

    test('composes with WHERE, and each filters its own level', () async {
      final owners = await db
          .select(pets.ownerId)
          .from(pets)
          .where(pets.name.notEquals('Milo'))
          .groupBy(pets.ownerId)
          .having(count(pets.id).greaterThan(0))
          .orderBy({pets.ownerId: Order.asc});

      // Milo is filtered out by WHERE before the groups are formed, so owner 1
      // is left with one pet and still passes HAVING.
      expect(owners, [1, 2]);
    });

    test('combines with & and |', () {
      final sql = sqlOf(
        db.select(pets.ownerId).from(pets).groupBy(pets.ownerId).having(
              count(pets.id).greaterThan(1) & count(pets.id).lessThan(10),
            ),
      );

      expect(sql, contains('HAVING COUNT("id") > \$1 AND COUNT("id") < \$2'));
    });

    test('is absent when not asked for', () {
      final sql =
          sqlOf(db.select(pets.ownerId).from(pets).groupBy(pets.ownerId));

      expect(sql, isNot(contains('HAVING')));
    });

    test('survives chaining without losing the builder type', () {
      // .having() returns the same builder class, so .derived() still resolves.
      final grouped = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .having(count(pets.id).greaterThan(0))
          .derived();

      expect(sqlOf(db.select(min(grouped.$2)).from(grouped)),
          contains('HAVING'));
    });
  });
}
