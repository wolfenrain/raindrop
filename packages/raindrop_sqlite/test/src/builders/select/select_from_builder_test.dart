import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../../_support/fixtures.dart';

void main() {
  late Database database;
  late Raindrop db;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: _SilentLogger());
    await db.execute(
      '''
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, "favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)''',
    );
    await db.execute(
      '''
CREATE TABLE pets (id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id INTEGER NOT NULL, name TEXT NOT NULL)''',
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

  tearDown(() => database.close());

  String sqlOf(Object builder) =>
      SQLiteDialect().translate((builder as ToQuery).compile()).$1;

  group('clause methods exist on every builder shape', () {
    test('whole-row', () async {
      final names = await db
          .select()
          .from(users)
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.name: Order.asc})
          .limit(2)
          .offset(1);

      expect(names, hasLength(2));
    });

    test('projection', () async {
      final rows = await db
          .select(users.name, users.age)
          .from(users)
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.age: Order.desc})
          .limit(2)
          .offset(0);

      expect(rows.first.$1, 'Sam');
    });

    test('single projection', () async {
      final names = await db
          .select(users.name)
          .from(users)
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.name: Order.desc})
          .limit(1)
          .offset(0);

      expect(names, ['Sam']);
    });

    test('the base class methods still work when the subtype is erased',
        () async {
      // prepareDerived and similar library code construct the BASE builder;
      // its own clause methods must behave identically to the overrides.
      final projected = db.select(users.name).from(users);
      final base = SelectFromBuilder<Schema<dynamic>, dynamic, String>(
        // ignore: invalid_use_of_internal_member internals are the point
        projected.executor,
        // ignore: invalid_use_of_internal_member internals are the point
        config: projected.config,
      );

      final names = await base
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.name: Order.asc})
          .limit(3)
          .offset(0);

      expect(names, ['Alex', 'Morgan', 'Sam']);
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
        contains(r'GROUP BY "owner_id" HAVING COUNT("id") > $1 ORDER BY'),
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

      expect(sql, contains(r'HAVING COUNT("id") > $1 AND COUNT("id") < $2'));
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

      expect(
          sqlOf(db.select(min(grouped.$2)).from(grouped)), contains('HAVING'));
    });
  });
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
