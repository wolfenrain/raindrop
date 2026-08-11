import 'package:raindrop/raindrop.dart';
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
    await db.insert(into: users).values([
      User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
      User(name: 'Alex', favoriteGame: 'tetris', age: 28),
      User(name: 'Sam', favoriteGame: 'doom', age: 41),
    ]);
  });

  tearDown(() => database.close());

  group('builder future members', () {
    test('firsts, lasts and singles', () async {
      final builder =
          db.select(users.name).from(users).orderBy({users.name: Order.asc});

      expect(await builder.first, 'Alex');
      expect(await builder.firstOrNull, 'Alex');
      expect(await builder.last, 'Sam');
      expect(await builder.lastOrNull, 'Sam');

      final one = db.select(users.name).from(users).limit(1);
      expect(await one.single, 'Morgan');
      expect(await one.singleOrNull, 'Morgan');

      final none =
          db.select(users.name).from(users).where(users.age.equals(999));
      expect(await none.firstOrNull, isNull);
      expect(await none.lastOrNull, isNull);
      expect(await none.singleOrNull, isNull);
    });

    test('Future members delegate to one cached execution', () async {
      final builder = db.select(users.name).from(users);

      expect(await builder.asStream().first, hasLength(3));
      expect(await builder.then((rows) => rows.length), 3);
      expect(
        await builder.timeout(Duration(seconds: 5)),
        hasLength(3),
      );
      expect(await builder.whenComplete(() {}), hasLength(3));
      expect(
        await builder.catchError((Object _) => <String>[]),
        hasLength(3),
      );
    });

    test('toString renders the SQL', () {
      expect(
        db.select(users.name).from(users).toString(),
        contains('SELECT "name" FROM "users"'),
      );
    });
  });
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
