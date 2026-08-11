import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../_support/fixtures.dart';

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
      User(name: 'Alex', favoriteGame: 'tetris', age: 20),
      User(name: 'Sam', favoriteGame: 'zelda', age: 40),
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
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
