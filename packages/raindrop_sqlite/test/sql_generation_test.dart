import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

import '_support/fixtures.dart';

void main() {
  final golden = GoldenTester(dialect: SQLiteDialect());

  group('Select', () {
    golden
      ..test('all columns', (db) => db.select().from(users))
      ..test(
        'single column',
        (db) => db.select(users.name).from(users),
      )
      ..test(
        'multiple columns',
        (db) => db.select(users.name, users.age).from(users),
      )
      ..test(
        'count aggregate',
        (db) => db.select(users.id.count()).from(users),
      )
      ..test(
        'with equals filter',
        (db) => db.select().from(users).where(users.name.equals('Morgan')),
      )
      ..test(
        'where AND combines filters',
        (db) => db.select().from(users).where(
              users.favoriteGame.equals('zelda') & users.name.equals('Morgan'),
            ),
      )
      ..test(
        'where OR combines filters',
        (db) => db.select().from(users).where(
              users.name.equals('Morgan') | users.name.equals('Alex'),
            ),
      )
      ..test(
        'with NOT filter',
        (db) => db.select().from(users).where(not(users.name.equals('Morgan'))),
      )
      ..test(
        'with LIKE',
        (db) => db.select().from(users).where(users.name.like('%est%')),
      )
      ..test(
        'with IS NULL on nullable column',
        (db) => db.select().from(users).where(users.deletedAt.isNull()),
      )
      ..test(
        'with greater than on int',
        (db) => db.select().from(users).where(users.age.greaterThan(18)),
      )
      ..test(
        'where compares against an expression',
        (db) => db.select().from(users).where(
              users.name.equals(Coalesce(users.favoriteGame, 'none')),
            ),
      )
      ..test(
        'where compares against arithmetic on a column',
        (db) =>
            db.select().from(users).where(users.age.greaterThan(users.age + 1)),
      )
      ..test(
        'with IN list',
        (db) => db.select().from(users).where(users.age.inList([18, 21, 30])),
      )
      ..test(
        'with IN list mixing a column and a literal',
        (db) =>
            db.select().from(users).where(users.age.inList([users.age, 30])),
      )
      ..test(
        'with IN list holding an expression',
        (db) => db.select().from(users).where(
              users.name
                  .inList([Coalesce(users.favoriteGame, 'none'), 'Morgan']),
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
        'with group by',
        (db) => db.select(users.name).from(users).groupBy(users.favoriteGame),
      )
      ..test(
        'with limit',
        (db) => db.select().from(users).limit(10),
      )
      ..test(
        'with limit and offset',
        (db) => db.select().from(users).limit(10).offset(20),
      )
      ..test(
        'with not equals filter',
        (db) => db.select().from(users).where(users.name.notEquals('Morgan')),
      )
      ..test(
        'with greater than or equal on int',
        (db) => db.select().from(users).where(users.age.greaterThanOrEqual(18)),
      )
      ..test(
        'with less than on int',
        (db) => db.select().from(users).where(users.age.lessThan(65)),
      )
      ..test(
        'with less than or equal on int',
        (db) => db.select().from(users).where(users.age.lessThanOrEqual(65)),
      )
      ..test(
        'with is not null on nullable column',
        (db) => db.select().from(users).where(users.deletedAt.isNotNull()),
      )
      ..test(
        'with boolean is true',
        (db) => db.select().from(users).where(users.isActive.isTrue()),
      )
      ..test(
        'with boolean is false',
        (db) => db.select().from(users).where(users.isActive.isFalse()),
      )
      ..test(
        'with double not equals',
        (db) => db.select().from(users).where(users.rating.notEquals(0.0)),
      )
      ..test(
        'with empty IN list is always false',
        (db) => db.select().from(users).where(users.age.inList([])),
      )
      ..test(
        'order by single ascending',
        (db) => db.select().from(users).orderBy({users.age: Order.asc}),
      )
      ..test(
        'order by single descending',
        (db) => db.select().from(users).orderBy({users.rating: Order.desc}),
      )
      ..test(
        'order by multiple terms',
        (db) => db.select().from(users).orderBy({
          users.age: Order.desc,
          users.name: Order.asc,
        }),
      )
      ..test(
        'with right join',
        (db) => db.select().from(users).rightJoin(
              pets,
              on: users.id.equals(pets.ownerId),
            ),
      )
      ..test(
        'all clauses combined',
        (db) => db
            .select()
            .from(users)
            .where(users.age.greaterThanOrEqual(18) & users.isActive.isTrue())
            .groupBy(users.favoriteGame)
            .orderBy({users.age: Order.desc})
            .limit(10)
            .offset(5),
      );
  });

  group('Insert', () {
    golden
      ..test(
        'single row',
        (db) => db.insert(into: users).values(
          [User(name: 'Morgan', favoriteGame: 'zelda', age: 30)],
        ),
      )
      ..test(
        'multiple rows',
        (db) => db.insert(into: users).values([
          User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
          User(name: 'Alex', favoriteGame: 'tetris', age: 28),
        ]),
      )
      ..test(
        'with returning',
        (db) => db.insert(into: users).values(
            [User(name: 'Morgan', favoriteGame: 'zelda', age: 30)]).returning(),
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
        'with returning',
        (db) => db
            .update(users)
            .set(users.name.to('Renamed'))
            .where(users.id.equals(1))
            .returning(),
      )
      ..test(
        'soft delete sets timestamp',
        (db) => db
            .update(users)
            .set(users.deletedAt.to(DateTime.utc(2026, 5, 13)))
            .where(users.id.equals(1)),
      )
      ..test(
        'with limit',
        (db) => db
            .update(users)
            .set(users.name.to('Renamed'))
            .where(users.age.greaterThan(18))
            .limit(5),
      )
      ..test(
        'with limit and no filter',
        (db) => db.update(users).set(users.name.to('Renamed')).limit(5),
      )
      ..test(
        'set to coalesce expression',
        (db) => db
            .update(users)
            .set(users.name.to(Coalesce(users.name, 'anon')))
            .where(users.id.equals(1)),
      )
      ..test(
        'set to arithmetic on the column itself',
        (db) => db
            .update(users)
            .set(users.age.to(users.age + 1))
            .where(users.id.equals(1)),
      )
      ..test(
        'set to another column',
        (db) => db.update(users).set(users.name.to(users.favoriteGame)),
      )
      ..test(
        'set all from a list',
        (db) => db
            .update(users)
            .setAll([users.name.to('Renamed'), users.age.to(31)]).where(
                users.id.equals(1)),
      );
  });

  group('Expression', () {
    golden
      ..test(
        'coalesce in select',
        (db) => db.select(Coalesce(users.name, 'anon')).from(users),
      )
      ..test(
        'coalesce in select with join',
        (db) => db
            .select(Coalesce(users.name, 'anon'), users.id)
            .from(users)
            .join(pets, on: users.id.equals(pets.ownerId)),
      )
      ..test(
        'min aggregate',
        (db) => db.select(min(users.age)).from(users),
      )
      ..test(
        'max aggregate',
        (db) => db.select(max(users.age)).from(users),
      )
      ..test(
        'count star (no column)',
        (db) => db.select(count()).from(users),
      )
      ..test(
        'coalesce top-level function',
        (db) => db.select(coalesce(users.age, 0)).from(users),
      );
  });

  group('Projection', () {
    golden
      ..test(
        'explicit columns with inner join (no table append)',
        (db) => db
            .select(users.id, users.name, pets.name)
            .from(users)
            .join(pets, on: users.id.equals(pets.ownerId)),
      )
      ..test(
        'explicit columns with left join',
        (db) => db
            .select(users.name, pets.name)
            .from(users)
            .leftJoin(pets, on: users.id.equals(pets.ownerId)),
      )
      ..test(
        'aggregate + join + group by + order by',
        (db) => db
            .select(users.id, users.name, count(pets.id))
            .from(users)
            .join(pets, on: users.id.equals(pets.ownerId))
            .groupBy(users.id)
            .orderBy({users.name: Order.asc}),
      )
      ..test(
        'nullable column projects as nullable',
        (db) => db.select(users.name, users.deletedAt).from(users),
      );
  });

  group('Delete', () {
    golden
      ..test('all rows', (db) => db.delete(from: users))
      ..test(
        'with where',
        (db) => db.delete(from: users).where(users.id.equals(1)),
      )
      ..test(
        'with OR filter',
        (db) => db.delete(from: users).where(
              users.name.equals('Morgan') | users.name.equals('Alex'),
            ),
      )
      ..test(
        'with returning',
        (db) => db.delete(from: users).where(users.id.equals(1)).returning(),
      )
      ..test(
        'with limit',
        (db) =>
            db.delete(from: users).where(users.age.greaterThan(0)).limit(10),
      );
  });

  group('LIMIT-enabled build', () {
    GoldenTester(
      dialect: const SQLiteDialect(supportsUpdateDeleteLimit: true),
    )
      ..test(
        'update with limit',
        (db) => db
            .update(users)
            .set(users.name.to('Renamed'))
            .where(users.age.greaterThan(18))
            .limit(5),
      )
      ..test(
        'update with limit and no filter',
        (db) => db.update(users).set(users.name.to('Renamed')).limit(5),
      )
      ..test(
        'delete with limit',
        (db) =>
            db.delete(from: users).where(users.age.greaterThan(0)).limit(10),
      );
  });
}
