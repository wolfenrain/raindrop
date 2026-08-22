import 'package:meta/meta.dart';
import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/src/conformance/fixture_operations.dart';
import 'package:raindrop_test/src/conformance/fixtures.dart';
import 'package:raindrop_test/src/conformance/harness.dart';
import 'package:test/test.dart';

/// Runs the shared driver conformance suite against [harness].
///
/// The suite verifies the behavior every raindrop driver must provide like
/// CRUD round-trips, filters, joins, aggregates, transaction semantics and
/// schema changes rendered by the driver's own `DdlGenerator`, plus
/// RETURNING when the driver declares support by passing [returning].
///
/// Every test gets a fresh, empty pair of fixture tables, created through
/// the driver's own `DdlGenerator` from the conformance schemas.
///
/// ```dart
/// void main() {
///   testDriverConformance(MyDriverHarness());
/// }
/// ```
@isTestGroup
void testDriverConformance(
  DriverTestHarness harness, {
  ReturningSupport? returning,
}) {
  group('driver conformance', () {
    var available = true;
    late RaindropDelegate delegate;
    late Raindrop db;

    setUpAll(() async {
      available = await harness.isAvailable();
    });

    setUp(() async {
      if (!available) return;
      delegate = await harness.open();
      db = Raindrop(delegate);
      await _createFixtureTables(db, harness.createDdlGenerator());
    });

    tearDown(() async {
      if (!available) return;
      await harness.close(delegate);
    });

    // Wraps `test` so an unavailable database skips instead of failing.
    @isTest
    void conformanceTest(String description, Future<void> Function() body) {
      test(description, () async {
        if (!available) return markTestSkipped('database unavailable');
        await body();
      });
    }

    /// Inserts three users and two pets, returning the stored users.
    ///
    /// Morgan (30, zelda, nicknamed) owns both pets, Alex (28, tetris) and
    /// Sam (41, doom) own none.
    Future<List<User>> seed() async {
      await db.insert(into: users).values([
        User(name: 'Morgan', favoriteGame: 'zelda', age: 30, nickname: 'Momo'),
        User(name: 'Alex', favoriteGame: 'tetris', age: 28),
        User(name: 'Sam', favoriteGame: 'doom', age: 41),
      ]);
      // Generated keys ascend in insertion order, so the select-back returns
      // the rows in the order they were written above.
      final stored =
          await db.select().from(users).orderBy({users.id: Order.asc});
      await db.insert(into: pets).values([
        Pet(name: 'Rex', ownerId: stored[0].id!),
        Pet(name: 'Milo', ownerId: stored[0].id!),
      ]);
      return stored;
    }

    group('insert', () {
      conformanceTest('stores a row that decodes back', () async {
        await db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
        ]);

        final row = await db.select().from(users).single;
        expect(row.id, isNotNull);
        expect(row.name, 'Morgan');
        expect(row.favoriteGame, 'zelda');
        expect(row.age, 30);
        expect(row.nickname, isNull);
      });

      conformanceTest('assigns distinct ascending keys', () async {
        final stored = await seed();

        expect(stored.map((u) => u.name), ['Morgan', 'Alex', 'Sam']);
        expect(stored.map((u) => u.id), everyElement(isNotNull));
        expect(stored.map((u) => u.id).toSet(), hasLength(3));
      });
    });

    group('select', () {
      conformanceTest('filters with equals and notEquals', () async {
        await seed();

        expect(
          await db.select(users.age).from(users).where(
                users.name.equals('Morgan'),
              ),
          [30],
        );
        expect(
          await db.select(users.name).from(users).where(
                users.name.notEquals('Morgan'),
              ),
          unorderedEquals(['Alex', 'Sam']),
        );
      });

      conformanceTest('filters with integer comparisons', () async {
        await seed();

        expect(
          await db.select(users.name).from(users).where(
                users.age.greaterThan(29),
              ),
          unorderedEquals(['Morgan', 'Sam']),
        );
        expect(
          await db.select(users.name).from(users).where(
                users.age.lessThanOrEqual(28),
              ),
          ['Alex'],
        );
      });

      conformanceTest('filters with inList and like', () async {
        await seed();

        expect(
          await db.select(users.name).from(users).where(
                users.name.inList(['Alex', 'Sam', 'Nobody']),
              ),
          unorderedEquals(['Alex', 'Sam']),
        );
        expect(
          await db.select(users.name).from(users).where(
                users.name.like('M%'),
              ),
          ['Morgan'],
        );
      });

      conformanceTest('filters on null and non-null columns', () async {
        await seed();

        expect(
          await db.select(users.name).from(users).where(
                users.nickname.isNull(),
              ),
          unorderedEquals(['Alex', 'Sam']),
        );
        expect(
          await db.select(users.name).from(users).where(
                users.nickname.isNotNull(),
              ),
          ['Morgan'],
        );
      });

      conformanceTest('combines filters with and, or and not', () async {
        await seed();

        expect(
          await db.select(users.name).from(users).where(
                users.age.greaterThan(29) & users.nickname.isNull(),
              ),
          ['Sam'],
        );
        expect(
          await db.select(users.name).from(users).where(
                users.name.equals('Alex') | users.name.equals('Sam'),
              ),
          unorderedEquals(['Alex', 'Sam']),
        );
        expect(
          await db.select(users.name).from(users).where(
                not(users.nickname.isNull()),
              ),
          ['Morgan'],
        );
      });

      conformanceTest('orders, limits and offsets', () async {
        await seed();

        expect(
          await db.select(users.name).from(users).orderBy(
            {users.age: Order.desc},
          ),
          ['Sam', 'Morgan', 'Alex'],
        );
        expect(
          await db
              .select(users.name)
              .from(users)
              .orderBy({users.age: Order.asc})
              .limit(1)
              .offset(1),
          ['Morgan'],
        );
      });

      conformanceTest('selects distinct values', () async {
        await seed();
        await db.insert(into: users).values([
          User(name: 'Robin', favoriteGame: 'zelda', age: 22),
        ]);

        final games = await db.select.distinct(users.favoriteGame).from(users);
        expect(games, hasLength(3));
        expect(games, unorderedEquals(['zelda', 'tetris', 'doom']));
      });

      conformanceTest('groups with aggregates', () async {
        await seed();
        await db.insert(into: users).values([
          User(name: 'Robin', favoriteGame: 'zelda', age: 22),
        ]);

        expect(
          await db
              .select(users.favoriteGame, users.id.count())
              .from(users)
              .groupBy(users.favoriteGame)
              .orderBy({users.favoriteGame: Order.asc}),
          [('doom', 1), ('tetris', 1), ('zelda', 2)],
        );
        expect(
          await db
              .select(users.favoriteGame)
              .from(users)
              .groupBy(users.favoriteGame)
              .having(users.id.count().greaterThan(1)),
          ['zelda'],
        );
        expect(await db.select(sum(users.age)).from(users), [121]);
        expect(await db.select(avg(users.age)).from(users), [30.25]);
      });

      conformanceTest('evaluates scalar expressions', () async {
        await db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30, nickname: ' M '),
        ]);

        expect(await db.select(upper(users.name)).from(users), ['MORGAN']);
        expect(await db.select(lower(users.name)).from(users), ['morgan']);
        expect(await db.select(trim(users.nickname)).from(users), ['M']);
        expect(await db.select(length(users.name)).from(users), [6]);
        expect(await db.select(users.age + 1).from(users), [31]);
        expect(await db.select(users.age % 7).from(users), [2]);
        expect(await db.select(abs(users.age - 60)).from(users), [30]);
      });

      conformanceTest('aggregates min and max', () async {
        await seed();

        expect(
          await db.select(min(users.age), max(users.age)).from(users),
          [(28, 41)],
        );
      });

      conformanceTest('falls back with coalesce', () async {
        await seed();

        expect(
          await db
              .select(coalesce(users.nickname, 'none'))
              .from(users)
              .orderBy({users.id: Order.asc}),
          ['Momo', 'none', 'none'],
        );
      });

      conformanceTest('filters with a subquery', () async {
        await seed();

        expect(
          await db.select(users.name).from(users).where(
                users.id.inQuery(db.select(pets.ownerId).from(pets)),
              ),
          ['Morgan'],
        );
        expect(
          await db.select(users.name).from(users).where(
                not(
                  exists(
                    db.select().from(pets).where(
                          users.id.equals(pets.ownerId),
                        ),
                  ),
                ),
              ),
          unorderedEquals(['Alex', 'Sam']),
        );
      });

      conformanceTest('selects from a derived table', () async {
        await seed();

        final counts = db
            .select(pets.ownerId, pets.id.count())
            .from(pets)
            .groupBy(pets.ownerId)
            .derived();

        expect(await db.select(max(counts.$2)).from(counts), [2]);
      });
    });

    group('joins', () {
      conformanceTest('inner join pairs matching rows', () async {
        await seed();

        expect(
          await db
              .select(users.name, pets.name)
              .from(users)
              .join(pets, on: users.id.equals(pets.ownerId))
              .orderBy({pets.name: Order.asc}),
          [('Morgan', 'Milo'), ('Morgan', 'Rex')],
        );
      });

      conformanceTest('left join keeps unmatched rows', () async {
        await seed();

        expect(
          await db
              .select(users.name, count(pets.id))
              .from(users)
              .leftJoin(pets, on: users.id.equals(pets.ownerId))
              .groupBy(users.id)
              .orderBy({users.name: Order.asc}),
          [('Alex', 0), ('Morgan', 2), ('Sam', 0)],
        );
      });

      conformanceTest('right join keeps unmatched rows', () async {
        await seed();

        expect(
          await db
              .select(count(pets.id), users.name)
              .from(pets)
              .rightJoin(users, on: users.id.equals(pets.ownerId))
              .groupBy(users.id)
              .orderBy({users.name: Order.asc}),
          [(0, 'Alex'), (2, 'Morgan'), (0, 'Sam')],
        );
      });
    });

    group('update', () {
      conformanceTest('rewrites only matching rows', () async {
        await seed();

        await db
            .update(users)
            .set(users.favoriteGame.to('myst'))
            .where(users.name.equals('Alex'));

        expect(
          await db.select(users.favoriteGame).from(users).where(
                users.name.equals('Alex'),
              ),
          ['myst'],
        );
        expect(
          await db.select(users.favoriteGame).from(users).where(
                users.name.equals('Sam'),
              ),
          ['doom'],
        );
      });

      conformanceTest('assigns from an expression', () async {
        await seed();

        await db
            .update(users)
            .set(users.age.to(users.age + 1))
            .where(users.name.equals('Alex'));

        expect(
          await db.select(users.age).from(users).where(
                users.name.equals('Alex'),
              ),
          [29],
        );
      });
    });

    group('delete', () {
      conformanceTest('removes only matching rows', () async {
        await seed();

        await db.delete(from: users).where(users.name.equals('Alex'));

        expect(
          await db.select(users.name).from(users),
          unorderedEquals(['Morgan', 'Sam']),
        );
      });

      conformanceTest('without a filter clears the table', () async {
        await seed();

        await db.delete(from: pets);

        expect(await db.select().from(pets), isEmpty);
      });
    });

    if (returning != null) {
      group('returning', () {
        conformanceTest('an insert yields the stored rows with keys', () async {
          final stored = await returning.insert(
            db.insert(into: users).values([
              User(name: 'Robin', favoriteGame: 'myst', age: 22),
            ]),
          );

          expect(stored.single.id, isNotNull);
          expect(stored.single.name, 'Robin');
          expect(stored.single.age, 22);
        });

        conformanceTest('an update yields the changed rows', () async {
          await seed();

          final updated = await returning.update(
            db
                .update(users)
                .set(users.nickname.to('Ace'))
                .where(users.name.equals('Alex')),
          );

          expect(updated.single.name, 'Alex');
          expect(updated.single.nickname, 'Ace');
        });

        conformanceTest('a delete yields the removed rows', () async {
          await seed();

          final removed = await returning.delete(
            db.delete(from: users).where(users.age.greaterThan(29)),
          );

          expect(
            removed.map((u) => u.name),
            unorderedEquals(['Morgan', 'Sam']),
          );
        });
      });
    }

    group('transaction', () {
      Future<void> insertUser(RaindropExecutor<Delegate> tx, String name) {
        return tx.insert(into: users).values([
          User(name: name, favoriteGame: 'zelda', age: 30),
        ]);
      }

      conformanceTest('commits its writes', () async {
        final result = await db.transaction((tx) async {
          await insertUser(tx, 'Morgan');
          return 42;
        });

        expect(result, 42);
        expect(await db.select(users.name).from(users), ['Morgan']);
      });

      conformanceTest('reads its own writes with builders', () async {
        final names = await db.transaction((tx) async {
          await insertUser(tx, 'Morgan');
          return tx.select(users.name).from(users);
        });

        expect(names, ['Morgan']);
      });

      conformanceTest('rolls back when the body throws', () async {
        await expectLater(
          db.transaction((tx) async {
            await insertUser(tx, 'Gone');
            throw const FormatException('abort');
          }),
          throwsFormatException,
        );

        expect(await db.select().from(users), isEmpty);
      });

      conformanceTest('rollback() aborts the transaction', () async {
        await expectLater(
          db.transaction((tx) async {
            await insertUser(tx, 'Gone');
            await tx.delegate.rollback();
          }),
          throwsA(isA<TransactionRollback>()),
        );

        expect(await db.select().from(users), isEmpty);
      });

      conformanceTest('a nested transaction rolls back to its savepoint',
          () async {
        await db.transaction((tx) async {
          await insertUser(tx, 'Kept');
          try {
            await tx.transaction((inner) async {
              await insertUser(inner, 'Undone');
              throw const FormatException('abort');
            });
          } on FormatException {
            // Only the savepoint should roll back.
          }
        });

        expect(await db.select(users.name).from(users), ['Kept']);
      });
    });

    group('schema changes', () {
      conformanceTest('an added column stores and reads back', () async {
        final usersTable = fixtureCreateTableOperations(db.delegate.dialect)
            .firstWhere((operation) => operation.table.name == 'users')
            .table;
        await _execute(
          db,
          harness.createDdlGenerator().generate([
            AlterTable(
              oldTable: usersTable,
              newTable: TableInfo(
                name: usersTable.name,
                columns: [
                  ...usersTable.columns,
                  const ColumnInfo(
                    name: 'motto',
                    type: 'TEXT',
                    isNullable: true,
                  ),
                ],
              ),
            ),
          ]),
        );

        final dialect = db.delegate.dialect;
        String name(String value) => dialect.escapeName(value);
        await db.execute(
          'INSERT INTO ${name('users')} '
          '(${name('name')}, ${name('favoriteGame')}, ${name('age')}, '
          '${name('motto')}) '
          'VALUES (${dialect.escapeParam(0)}, ${dialect.escapeParam(1)}, '
          '${dialect.escapeParam(2)}, ${dialect.escapeParam(3)})',
          ['Morgan', 'zelda', 30, 'carpe diem'],
        );
        expect(
          await db.select(raw<String?>(name('motto'))).from(users),
          ['carpe diem'],
        );
      });

      conformanceTest('a created unique index enforces until dropped',
          () async {
        const index = IndexInfo(
          name: 'users_name_unique',
          tableName: 'users',
          columns: ['name'],
          isUnique: true,
        );
        Future<void> insertMorgan() => db.insert(into: users).values([
              User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
            ]);
        final generator = harness.createDdlGenerator();

        await _execute(
            db, generator.generate([const CreateIndex(index: index)]));
        await insertMorgan();
        await expectLater(insertMorgan(), throwsA(isA<Exception>()));

        await _execute(
          db,
          generator.generate(
            [const DropIndex('users_name_unique', tableName: 'users')],
          ),
        );
        await insertMorgan();
        expect(await db.select().from(users), hasLength(2));
      });

      conformanceTest('a dropped table is gone', () async {
        await _execute(
          db,
          harness.createDdlGenerator().generate([const DropTable('pets')]),
        );

        await expectLater(db.select().from(pets), throwsA(isA<Exception>()));
      });
    });
  });
}

Future<void> _createFixtureTables(Raindrop db, DdlGenerator generator) async {
  final dialect = db.delegate.dialect;
  for (final name in [pets.$.name, users.$.name]) {
    await db.execute('DROP TABLE IF EXISTS ${dialect.escapeName(name)}');
  }

  await _execute(db, generator.generate(fixtureCreateTableOperations(dialect)));
}

/// Executes every statement of [sql] through [db], split by its dialect.
Future<void> _execute(Raindrop db, String sql) async {
  for (final statement in db.delegate.dialect.splitStatements(sql)) {
    await db.execute(statement);
  }
}
