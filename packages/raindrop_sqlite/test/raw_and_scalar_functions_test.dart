import 'package:raindrop/dialect.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'sql_generation_test.dart' show User, users;

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
      'CREATE TABLE users ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, '
      '"favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, '
      'is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)',
    );
    await db.insert(into: users).values([
      User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
      User(name: 'Sam', favoriteGame: 'doom', age: -4),
    ]);
  });

  tearDown(() => database.dispose());

  String sqlOf(Object builder) =>
      const SQLiteDialect().translate((builder as ToQuery).compile()).$1;

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
      final (sql, values) = const SQLiteDialect().translate(
        (db.select(users.name).from(users).where(
              raw.parts([users.age, '>', 18]),
            ) as ToQuery)
            .compile(),
      );

      expect(sql, contains(r'WHERE "age" > $1'));
      expect(values, [18]);
    });

    test('bind() forces a string to travel as a value', () async {
      const input = "Morgan'; DROP TABLE users; --";
      final (sql, values) = const SQLiteDialect().translate(
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

  group('scalar functions', () {
    test('length', () async {
      final names = await db
          .select(users.name)
          .from(users)
          .where(length(users.name).greaterThan(3));

      expect(names, ['Morgan']);
    });

    test('lower and upper', () async {
      final folded =
          await db.select(lower(users.name), upper(users.name)).from(users);

      expect(folded, [('morgan', 'MORGAN'), ('sam', 'SAM')]);
    });

    test('abs keeps the column type', () async {
      final List<int> ages = await db.select(abs(users.age)).from(users);

      expect(ages, [30, 4]);
    });

    test('trim', () async {
      await db
          .insert(into: users)
          .values([User(name: '  pad  ', favoriteGame: 'x', age: 1)]);
      final trimmed = await db
          .select(trim(users.name))
          .from(users)
          .where(users.age.equals(1));

      expect(trimmed, ['pad']);
    });

    test('render as plain function calls', () {
      final sql = sqlOf(db.select(length(users.name)).from(users));

      expect(sql, contains('LENGTH("name")'));
    });
  });
}
