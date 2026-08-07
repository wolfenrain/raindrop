import 'package:raindrop/raindrop.dart';
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
      'CREATE TABLE users ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, '
      '"favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, '
      'is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)',
    );
    await db.execute(
      'CREATE TABLE pets ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, owner_id INTEGER NOT NULL, '
      'name TEXT NOT NULL)',
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

  group('IN', () {
    test('matches the rows the query returns', () async {
      final named = await db
          .select(users.name)
          .from(users)
          .where(users.id.inQuery(db.select(pets.ownerId).from(pets)))
          .orderBy({users.name: Order.asc});

      expect(named, ['Alex', 'Morgan']);
    });

    test('a multi-row query is fine, which IN (list) could not express',
        () async {
      final count = await db
          .select(users.id.count())
          .from(users)
          .where(users.id.inQuery(db.select(pets.ownerId).from(pets)));

      expect(count.single, 2);
    });
  });

  group('EXISTS', () {
    test('correlates against the outer row', () async {
      final named = await db
          .select(users.name)
          .from(users)
          .where(
            exists(
              db.select().from(pets).where(users.id.equals(pets.ownerId)),
            ),
          )
          .orderBy({users.name: Order.asc});

      expect(named, ['Alex', 'Morgan']);
    });

    test('not() is the complement, no notExists needed', () async {
      final named = await db.select(users.name).from(users).where(
            not(
              exists(
                db.select().from(pets).where(users.id.equals(pets.ownerId)),
              ),
            ),
          );

      expect(named, ['Sam']);
    });

    test('negation renders through the existing NOT wrapper', () {
      final query = db.select(users.name).from(users).where(
            not(
              exists(
                db.select().from(pets).where(users.id.equals(pets.ownerId)),
              ),
            ),
          );

      final (sql, _) =
          const SQLiteDialect().translate((query as ToQuery).compile());

      expect(sql, contains('NOT (EXISTS ('));
    });

    test('composes with other filters', () async {
      final named = await db.select(users.name).from(users).where(
            users.age.greaterThan(20) &
                exists(
                  db.select().from(pets).where(users.id.equals(pets.ownerId)),
                ),
          );

      expect(named, isNotEmpty);
    });
  });

  group('scalar position', () {
    test('compares against a subquery', () async {
      final youngest = subquery(db.select(min(users.age)).from(users));
      final named = await db
          .select(users.name)
          .from(users)
          .where(users.age.equals(youngest));

      expect(named.single, 'Alex');
    });

    test('rides in a projection and keeps its type', () async {
      final rows = await db.select(
        users.name,
        subquery(
          db.select(count(pets.id)).from(pets).where(
                users.id.equals(pets.ownerId),
              ),
        ),
      ).from(users).orderBy({users.name: Order.asc});

      expect(rows, [('Alex', 1), ('Morgan', 2), ('Sam', 0)]);
    });
  });

  group('derived', derivedTests);

  group('IN collapse', inListCollapseTests);

  group('rendering', () {
    // The real check on nested rendering: binds have to interleave in source
    // order across the outer projection, the subquery, and the outer where. A
    // subquery translated on its own would restart numbering at $1.
    test('binds interleave with the outer statement in order', () {
      final query = db
          .select(users.name)
          .from(users)
          .where(
            users.favoriteGame.equals('zelda') &
                users.id.inQuery(
                  db
                      .select(pets.ownerId)
                      .from(pets)
                      .where(pets.name.equals('Rex')),
                ) &
                users.age.greaterThan(18),
          );

      final (sql, values) =
          const SQLiteDialect().translate((query as ToQuery).compile());

      expect(values, ['zelda', 'Rex', 18]);
      expect(sql, contains(r'= $1'));
      expect(sql, contains(r'= $2'));
      expect(sql, contains(r'> $3'));
    });

    test('a correlated subquery qualifies its columns', () {
      final query = db.select(users.name).from(users).where(
            exists(
              db.select().from(pets).where(users.id.equals(pets.ownerId)),
            ),
          );

      final (sql, _) =
          const SQLiteDialect().translate((query as ToQuery).compile());

      expect(sql, contains('"users"."id" = "pets"."owner_id"'));
    });
  });
}

// Appended: derived tables (FROM position).
void derivedTests() {
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
      User(name: 'Alex', favoriteGame: 'tetris', age: 28, isActive: false),
      User(name: 'Sam', favoriteGame: 'doom', age: 41),
    ]);
  });

  tearDown(() => database.dispose());

  test('selects whole rows through the derived table', () async {
    final active =
        db.select().from(users).where(users.isActive.isTrue()).derived();
    final rows = await db.select().from(active);

    expect(rows.map((u) => u.name), containsAll(['Morgan', 'Sam']));
  });

  test('the base column handles still resolve against it', () async {
    final active =
        db.select().from(users).where(users.isActive.isTrue()).derived();
    final rows = await db
        .select(users.name)
        .from(active)
        .where(users.age.greaterThan(35));

    expect(rows, ['Sam']);
  });

  test('renders as a named statement in FROM', () {
    final active =
        db.select().from(users).where(users.isActive.isTrue()).derived();
    final query = db.select(users.name).from(active);

    final (sql, _) =
        const SQLiteDialect().translate((query as ToQuery).compile());

    expect(sql, contains('FROM (SELECT'));
    expect(sql, contains('AS "users"'));
  });
}

// Appended: the two spellings must agree.
void inListCollapseTests() {
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
  });

  tearDown(() => database.dispose());

  String sqlOf(Object builder) =>
      const SQLiteDialect().translate((builder as ToQuery).compile()).$1;

  test('a lone subquery in a list renders without the extra parens', () {
    final sub = subquery(db.select(pets.ownerId).from(pets));
    final sql = sqlOf(db.select(users.name).from(users).where(
          users.id.inList([sub]),
        ));

    expect(sql, contains('IN (SELECT'));
    expect(sql, isNot(contains('IN ((SELECT')));
  });

  test('inList and inQuery agree exactly', () {
    final a = sqlOf(db.select(users.name).from(users).where(
          users.id.inList([subquery(db.select(pets.ownerId).from(pets))]),
        ));
    final b = sqlOf(db.select(users.name).from(users).where(
          users.id.inQuery(db.select(pets.ownerId).from(pets)),
        ));

    expect(a, b);
  });

  // The collapse is for ONE subquery only: several are a genuine list of
  // scalars and must keep their parens.
  test('two subqueries stay a list', () {
    final sql = sqlOf(db.select(users.name).from(users).where(
          users.id.inList([
            subquery(db.select(pets.ownerId).from(pets)),
            subquery(db.select(pets.id).from(pets)),
          ]),
        ));

    expect(sql, contains('IN ((SELECT'));
  });

  test('a plain list is untouched', () {
    final sql = sqlOf(
      db.select(users.name).from(users).where(users.age.inList([18, 21])),
    );

    expect(sql, contains(r'IN ($1, $2)'));
  });
}
