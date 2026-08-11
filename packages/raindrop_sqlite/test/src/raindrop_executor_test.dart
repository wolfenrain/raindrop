import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../_support/fixtures.dart';

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

  group('executor', () {
    test('using the main executor inside a transaction throws', () async {
      await expectLater(
        db.transaction((tx) async {
          await db.execute('SELECT 1');
        }),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('main database executor inside a transaction'),
          ),
        ),
      );
    });

    test('using a parent transaction inside a nested one throws', () async {
      await expectLater(
        db.transaction((tx) async {
          await tx.transaction((inner) async {
            await tx.execute('SELECT 1');
          });
        }),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('parent transaction executor'),
          ),
        ),
      );
    });

    test('wide records decode at every arity', () async {
      final three = await db
          .select(users.name, users.age, users.rating)
          .from(users)
          .limit(1);
      expect(three.single.$1, 'Morgan');

      final five = await db
          .select(
              users.name, users.age, users.rating, users.id, users.favoriteGame)
          .from(users)
          .limit(1);
      expect(five.single.$5, 'zelda');

      final eight = await db
          .select(users.name, users.age, users.rating, users.id,
              users.favoriteGame, users.isActive, users.deletedAt, users.name)
          .from(users)
          .limit(1);
      expect(eight.single.$8, 'Morgan');
    });

    test('a whole row and an expression decode side by side', () async {
      final rows =
          await db.select(users, length(users.name)).from(users).limit(1);
      expect(rows.single.$1.name, 'Morgan');
      expect(rows.single.$2, 6);
    });
  });
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
