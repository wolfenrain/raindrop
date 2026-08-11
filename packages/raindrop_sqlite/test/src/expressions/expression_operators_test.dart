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
      expect(
          sqlOf(db
              .select(pets.ownerId)
              .from(pets)
              .groupBy(pets.ownerId)
              .having(count(pets.id).equals(2))),
          contains(r'COUNT("id") = $1'));
      expect(
          sqlOf(db
              .select(pets.ownerId)
              .from(pets)
              .groupBy(pets.ownerId)
              .having(count(pets.id).notEquals(2))),
          contains(r'COUNT("id") != $1'));
      expect(
          sqlOf(db
              .select(pets.ownerId)
              .from(pets)
              .groupBy(pets.ownerId)
              .having(count(pets.id).lessThan(2))),
          contains(r'COUNT("id") < $1'));
      expect(
        sqlOf(db
            .select(pets.ownerId)
            .from(pets)
            .groupBy(pets.ownerId)
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

  test('expression comparisons cover the whole matrix', () async {
    final subject = length(users.name);
    final rows = await db.select(users.name).from(users).where(
          subject.notEquals(0) &
              subject.lessThan(100) &
              subject.lessThanOrEqual(100) &
              subject.greaterThanOrEqual(1) &
              subject.inList([3, 4, 5, 6]) &
              subject.isNotNull() &
              not(subject.isNull()) &
              lower(users.name).like('m%'),
        );

    expect(rows, ['Morgan']);
  });
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
