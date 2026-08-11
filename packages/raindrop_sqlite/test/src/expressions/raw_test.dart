import 'package:raindrop/dialect.dart';
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
      User(name: 'Sam', favoriteGame: 'doom', age: -4),
    ]);
  });

  tearDown(() => database.close());

  String sqlOf(Object builder) =>
      SQLiteDialect().translate((builder as ToQuery).compile()).$1;

  group('raw()', () {
    test('is a predicate', () async {
      final names =
          await db.select(users.name).from(users).where(raw('"age" > 0'));

      expect(names, ['Morgan']);
    });

    test('composes with typed filters', () async {
      final names = await db
          .select(users.name)
          .from(users)
          .where(raw('"age" > 0') & users.name.equals('Morgan'));

      expect(names, ['Morgan']);
    });

    test('is a typed value in a projection', () async {
      final lengths = await db.select(raw<int>('LENGTH("name")')).from(users);

      expect(lengths, [6, 3]);
    });

    test('renders verbatim', () {
      final sql = sqlOf(
        db.select(users.name).from(users).where(raw('"age" % 2 = 0')),
      );

      expect(sql, contains('WHERE "age" % 2 = 0'));
    });
  });

  group('raw.parts', () {
    test('a column handle renders as a handle, not text', () async {
      final names = await db
          .select(users.name)
          .from(users)
          .where(raw.parts([users.age, '> 0']));

      expect(names, ['Morgan']);
      final sql = sqlOf(
        db.select(users.name).from(users).where(raw.parts([users.age, '> 0'])),
      );
      expect(sql, contains('WHERE "age" > 0'));
    });

    test('a non-string part becomes a bound parameter', () {
      final (sql, values) = SQLiteDialect().translate(
        (db.select(users.name).from(users).where(
                  raw.parts([users.age, '>', 18]),
                ) as ToQuery)
            .compile(),
      );

      expect(sql, contains(r'WHERE "age" > $1'));
      expect(values, [18]);
    });

    test('bind() forces a string to travel as a value', () async {
      final input = "Morgan'; DROP TABLE users; --";
      final (sql, values) = SQLiteDialect().translate(
        (db.select(users.name).from(users).where(
                  raw.parts([users.name, '=', bind(input)]),
                ) as ToQuery)
            .compile(),
      );

      expect(sql, contains(r'WHERE "name" = $1'));
      expect(values, [input]);

      // And the malicious text matches nothing rather than executing.
      final names = await db
          .select(users.name)
          .from(users)
          .where(raw.parts([users.name, '=', bind(input)]));
      expect(names, isEmpty);
    });

    test('is a typed value in a projection', () async {
      final lengths = await db
          .select(raw.parts<int>(['LENGTH(', users.name, ')']))
          .from(users);

      expect(lengths, [6, 3]);
    });

    test('composes with typed filters', () async {
      final names = await db
          .select(users.name)
          .from(users)
          .where(raw.parts([users.age, '> 0']) & users.name.equals('Morgan'));

      expect(names, ['Morgan']);
    });
  });
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
