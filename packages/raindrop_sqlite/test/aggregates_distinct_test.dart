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
      User(name: 'Alex', favoriteGame: 'tetris', age: 20),
      User(name: 'Sam', favoriteGame: 'zelda', age: 40),
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

  group('sum', () {
    test('totals a column', () async {
      final total = await db.select(sum(users.age)).from(users);
      expect(total.single, 90);
    });

    test('keeps the column type', () async {
      final total = await db.select(sum(users.age)).from(users);
      expect(total.single, isA<int>());
    });

    test('works per group and can be compared in HAVING', () async {
      final owners = await db
          .select(pets.ownerId)
          .from(pets)
          .groupBy(pets.ownerId)
          .having(sum(pets.id).greaterThan(2));

      expect(owners, [1, 2]);
    });
  });

  group('avg', () {
    test('is a double even over an int column', () async {
      final mean = await db.select(avg(users.age)).from(users);
      expect(mean.single, closeTo(30.0, 0.001));
    });

    test('renders as AVG', () {
      expect(sqlOf(db.select(avg(users.age)).from(users)), contains('AVG('));
    });
  });

  group('distinct inside an aggregate', () {
    test('counts each value once', () async {
      final distinctGames =
          await db.select(count(distinct(users.favoriteGame))).from(users);
      final allGames = await db.select(count(users.favoriteGame)).from(users);

      expect(distinctGames.single, 2); // zelda, tetris
      expect(allGames.single, 3);
    });

    test('renders without a stray comma', () {
      expect(
        sqlOf(db.select(count(distinct(users.favoriteGame))).from(users)),
        contains('COUNT(DISTINCT "favoriteGame")'),
      );
    });

    test('composes with sum', () {
      expect(
        sqlOf(db.select(sum(distinct(users.age))).from(users)),
        contains('SUM(DISTINCT "age")'),
      );
    });
  });

  group('SELECT DISTINCT', () {
    test('drops duplicate rows', () async {
      final games = await db.select
          .distinct(users.favoriteGame)
          .from(users)
          .orderBy({users.favoriteGame: Order.asc});

      expect(games, ['tetris', 'zelda']);
    });

    test('is absent unless asked for', () {
      final plain = sqlOf(db.select(users.favoriteGame).from(users));
      expect(plain, startsWith('SELECT "favoriteGame"'));
      expect(plain, isNot(contains('DISTINCT')));
    });

    test('covers every column of the projection', () {
      final sql =
          sqlOf(db.select.distinct(users.favoriteGame, users.age).from(users));

      expect(sql, startsWith('SELECT DISTINCT "favoriteGame", "age"'));
    });

    test('leaves the element type alone', () async {
      final games = await db.select.distinct(users.favoriteGame).from(users);

      expect(games, hasLength(2));
    });

    test('works on a whole row', () {
      expect(
        sqlOf(db.select.distinct().from(users)),
        startsWith('SELECT DISTINCT "id", "name"'),
      );
    });

    test('survives the rest of the chain', () {
      final sql = sqlOf(
        db.select
            .distinct(users.favoriteGame)
            .from(users)
            .where(users.age.greaterThan(21))
            .limit(5),
      );

      expect(sql, startsWith('SELECT DISTINCT'));
      expect(sql, contains('WHERE'));
      expect(sql, contains('LIMIT'));
    });
  });
}
