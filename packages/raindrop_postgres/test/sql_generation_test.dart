import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

import '_support/fixtures.dart';

void main() {
  final golden = GoldenTester(dialect: PostgresDialect());

  group('Select', () {
    golden
      ..test('all columns', (db) => db.select().from(users))
      ..test('single column', (db) => db.select(users.name).from(users))
      ..test('count aggregate', (db) => db.select(users.id.count()).from(users))
      ..test(
        'with equals filter',
        (db) => db.select().from(users).where(users.name.equals('Morgan')),
      )
      ..test(
        'with boolean filter',
        (db) => db.select().from(users).where(users.isActive.isTrue()),
      )
      ..test(
        'with is null filter',
        (db) => db.select().from(users).where(users.deletedAt.isNull()),
      )
      ..test(
        'with greater than filter',
        (db) => db.select().from(users).where(users.age.greaterThan(18)),
      )
      ..test(
        'with date time filter',
        (db) => db.select().from(users).where(
              users.deletedAt.equals(DateTime.utc(2026)),
            ),
      )
      ..test(
        'with inner join',
        (db) => db.select().from(users).join(
              pets,
              on: users.id.equals(pets.ownerId),
            ),
      )
      ..test(
        'with left join',
        (db) => db.select().from(users).leftJoin(
              pets,
              on: users.id.equals(pets.ownerId),
            ),
      )
      ..test(
        'with group by and order by',
        (db) => db
            .select(users.favoriteGame)
            .from(users)
            .groupBy(users.favoriteGame)
            .orderBy({users.favoriteGame: Order.asc}),
      )
      ..test(
        'with multiple group by terms',
        (db) => db
            .select(users.favoriteGame)
            .from(users)
            .groupBy(users.favoriteGame, users.age),
      )
      ..test(
        'with limit and offset',
        (db) => db.select().from(users).limit(10).offset(20),
      );
  });

  group('Insert', () {
    golden
      ..test(
        'a row',
        (db) => db.insert(into: pets).values([
          Pet(name: 'Rex', ownerId: 1),
        ]),
      )
      ..test(
        'a row with a bound date time',
        (db) => db.insert(into: users).values([
          User(
            name: 'Morgan',
            favoriteGame: 'zelda',
            age: 30,
            deletedAt: DateTime.utc(2026, 5, 13),
          ),
        ]),
      )
      ..test(
        'with returning',
        (db) => db.insert(into: pets).values([
          Pet(name: 'Rex', ownerId: 1),
        ]).returning(),
      )
      ..test(
        'on conflict do nothing',
        (db) => db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
        ]).onConflict([users.name], DoNothing()),
      )
      ..test(
        'on conflict without a target',
        (db) => db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
        ]).onConflict([], DoNothing()),
      )
      ..test(
        'on conflict do update',
        (db) => db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
        ]).onConflict(
          [users.name],
          DoUpdate([users.favoriteGame.to('tetris'), users.age.to(31)]),
        ),
      )
      ..test(
        'on conflict do update with returning',
        (db) => db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
        ]).onConflict([users.name], DoUpdate([users.age.to(31)])).returning(),
      );
  });

  group('Update', () {
    golden
      ..test(
        'single column',
        (db) => db
            .update(users)
            .set(users.name.to('Renamed'))
            .where(users.id.equals(1)),
      )
      ..test(
        'multiple columns',
        (db) => db
            .update(users)
            .set(users.name.to('Renamed'), users.age.to(31))
            .where(users.id.equals(1)),
      )
      ..test(
        'soft delete via expression',
        (db) => db
            .update(users)
            .set(users.deletedAt.to(now()))
            .where(users.id.equals(1)),
      )
      ..test(
        'with returning',
        (db) => db
            .update(users)
            .set(users.name.to('Renamed'))
            .where(users.id.equals(1))
            .returning(),
      );
  });

  group('Delete', () {
    golden
      ..test('all rows', (db) => db.delete(from: pets))
      ..test(
        'with filter',
        (db) => db.delete(from: pets).where(pets.ownerId.equals(1)),
      )
      ..test(
        'with returning',
        (db) => db.delete(from: users).where(users.id.equals(1)).returning(),
      );
  });

  group('Expressions', () {
    golden
      ..test(
        'now as a selection',
        (db) => db.select(now()).from(users),
      )
      ..test(
        'gen_random_uuid as a selection',
        (db) => db.select(genRandomUuid().as('uuid')).from(users),
      );
  });
}
