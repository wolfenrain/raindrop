import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

import '_support/sql_golden.dart';

class User {
  User({
    required this.name,
    required this.favoriteGame,
    required this.age,
    this.isActive = true,
    this.rating = 0,
    this.deletedAt,
    this.id,
  });

  final int? id;
  final String name;
  final String favoriteGame;
  final int age;
  final bool isActive;
  final double rating;
  final DateTime? deletedAt;
}

class UserSchema extends Schema<User> {
  UserSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name),
        favoriteGame = $.text('favoriteGame', (s) => s.favoriteGame),
        age = $.integer('age', (s) => s.age),
        isActive = $.boolean('is_active', (s) => s.isActive),
        rating = $.real('rating', (s) => s.rating),
        deletedAt = $.dateTime('deletedAt', (s) => s.deletedAt);

  @override
  User fromRow(RowReader read) => User(
        id: read(id),
        name: read(name)!,
        favoriteGame: read(favoriteGame)!,
        age: read(age)!,
        isActive: read(isActive)!,
        rating: read(rating)!,
        deletedAt: read(deletedAt),
      );

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<String> favoriteGame;
  final ColumnType<int> age;
  final ColumnType<bool> isActive;
  final ColumnType<double> rating;
  final ColumnType<DateTime?> deletedAt;
}

final users = sqliteTable('users', UserSchema.new);

class Pet {
  Pet({required this.name, required this.ownerId, this.id});

  final int? id;
  final int ownerId;
  final String name;
}

class PetSchema extends Schema<Pet> {
  PetSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        ownerId = $.integer('owner_id', (s) => s.ownerId),
        name = $.text('name', (s) => s.name);

  @override
  Pet fromRow(RowReader read) => Pet(
        id: read(id),
        ownerId: read(ownerId)!,
        name: read(name)!,
      );

  final ColumnType<int?> id;
  final ColumnType<int> ownerId;
  final ColumnType<String> name;
}

final pets = sqliteTable('pets', PetSchema.new);

void main() {
  group('Select', () {
    goldenTest('all columns', (db) => db.select().from(users));

    goldenTest(
      'single column',
      (db) => db.select(users.name).from(users),
    );

    goldenTest(
      'multiple columns',
      (db) => db.select(users.name, users.age).from(users),
    );

    goldenTest(
      'count aggregate',
      (db) => db.select(users.id.count()).from(users),
    );

    goldenTest(
      'with equals filter',
      (db) => db.select().from(users).where(users.name.equals('Morgan')),
    );

    goldenTest(
      'where AND combines filters',
      (db) => db.select().from(users).where(
            users.favoriteGame.equals('zelda') & users.name.equals('Morgan'),
          ),
    );

    goldenTest(
      'where OR combines filters',
      (db) => db.select().from(users).where(
            users.name.equals('Morgan') | users.name.equals('Alex'),
          ),
    );

    goldenTest(
      'with NOT filter',
      (db) => db.select().from(users).where(not(users.name.equals('Morgan'))),
    );

    goldenTest(
      'with LIKE',
      (db) => db.select().from(users).where(users.name.like('%est%')),
    );

    goldenTest(
      'with IS NULL on nullable column',
      (db) => db.select().from(users).where(users.deletedAt!.isNull()),
    );

    goldenTest(
      'with greater than on int',
      (db) => db.select().from(users).where(users.age.greaterThan(18)),
    );

    goldenTest(
      'with IN list',
      (db) => db.select().from(users).where(users.age.inList([18, 21, 30])),
    );

    goldenTest(
      'with inner join',
      (db) => db.select().from(users).join(
            pets,
            on: users.id.equals(pets.ownerId),
          ),
    );

    goldenTest(
      'with left join',
      (db) => db.select().from(users).leftJoin(
            pets,
            on: users.id.equals(pets.ownerId),
          ),
    );

    goldenTest(
      'with group by',
      (db) => db.select(users.name).from(users).groupBy(users.favoriteGame),
    );

    goldenTest(
      'with limit',
      (db) => db.select().from(users).limit(10),
    );

    goldenTest(
      'with limit and offset',
      (db) => db.select().from(users).limit(10).offset(20),
    );

    goldenTest(
      'with not equals filter',
      (db) => db.select().from(users).where(users.name.notEquals('Morgan')),
    );

    goldenTest(
      'with greater than or equal on int',
      (db) =>
          db.select().from(users).where(users.age.greaterThanOrEqual(18)),
    );

    goldenTest(
      'with less than on int',
      (db) => db.select().from(users).where(users.age.lessThan(65)),
    );

    goldenTest(
      'with less than or equal on int',
      (db) => db.select().from(users).where(users.age.lessThanOrEqual(65)),
    );

    goldenTest(
      'with is not null on nullable column',
      (db) => db.select().from(users).where(users.deletedAt!.isNotNull()),
    );

    goldenTest(
      'with boolean is true',
      (db) => db.select().from(users).where(users.isActive.isTrue()),
    );

    goldenTest(
      'with boolean is false',
      (db) => db.select().from(users).where(users.isActive.isFalse()),
    );

    goldenTest(
      'with double not equals',
      (db) => db.select().from(users).where(users.rating.notEquals(0.0)),
    );

    goldenTest(
      'with empty IN list is always false',
      (db) => db.select().from(users).where(users.age.inList([])),
    );

    goldenTest(
      'order by single ascending',
      (db) => db.select().from(users).orderBy({users.age: Order.asc}),
    );

    goldenTest(
      'order by single descending',
      (db) => db.select().from(users).orderBy({users.rating: Order.desc}),
    );

    goldenTest(
      'order by multiple terms',
      (db) => db.select().from(users).orderBy({
            users.age: Order.desc,
            users.name: Order.asc,
          }),
    );

    goldenTest(
      'with right join',
      (db) => db.select().from(users).rightJoin(
            pets,
            on: users.id.equals(pets.ownerId),
          ),
    );

    goldenTest(
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
    goldenTest(
      'single row',
      (db) => db.insert(into: users).values(
        [User(name: 'Morgan', favoriteGame: 'zelda', age: 30)],
      ),
    );

    goldenTest(
      'multiple rows',
      (db) => db.insert(into: users).values([
        User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
        User(name: 'Alex', favoriteGame: 'tetris', age: 28),
      ]),
    );

    goldenTest(
      'with returning',
      (db) => db.insert(into: users).values(
          [User(name: 'Morgan', favoriteGame: 'zelda', age: 30)]).returning(),
    );
  });

  group('Update', () {
    goldenTest(
      'single column',
      (db) => db
          .update(users)
          .set(users.name.to('Renamed'))
          .where(users.id.equals(1)),
    );

    goldenTest(
      'multiple columns',
      (db) => db
          .update(users)
          .set(users.name.to('Renamed'), users.age.to(31))
          .where(users.id.equals(1)),
    );

    goldenTest(
      'with returning',
      (db) => db
          .update(users)
          .set(users.name.to('Renamed'))
          .where(users.id.equals(1))
          .returning(),
    );

    goldenTest(
      'soft delete sets timestamp',
      (db) => db
          .update(users)
          .set(users.deletedAt!.to(DateTime.utc(2026, 5, 13)))
          .where(users.id.equals(1)),
    );

    goldenTest(
      'with limit',
      (db) => db
          .update(users)
          .set(users.name.to('Renamed'))
          .where(users.age.greaterThan(18))
          .limit(5),
    );

    goldenTest(
      'set to coalesce expression',
      (db) => db
          .update(users)
          .set(users.name.toExpression(Coalesce(users.name, 'anon')))
          .where(users.id.equals(1)),
    );

    goldenTest(
      'set all from a list',
      (db) => db
          .update(users)
          .setAll([users.name.to('Renamed'), users.age.to(31)])
          .where(users.id.equals(1)),
    );
  });

  group('Expression', () {
    goldenTest(
      'coalesce in select',
      (db) => db.select(Coalesce(users.name, 'anon')).from(users),
    );

    goldenTest(
      'coalesce in select with join',
      (db) => db
          .select(Coalesce(users.name, 'anon'), users.id)
          .from(users)
          .join(pets, on: users.id.equals(pets.ownerId)),
    );

    goldenTest(
      'min aggregate',
      (db) => db.select(min(users.age)).from(users),
    );

    goldenTest(
      'max aggregate',
      (db) => db.select(max(users.age)).from(users),
    );

    goldenTest(
      'count star (no column)',
      (db) => db.select(count()).from(users),
    );

    goldenTest(
      'coalesce top-level function',
      (db) => db.select(coalesce(users.age, 0)).from(users),
    );
  });

  group('Projection', () {
    goldenTest(
      'explicit columns with inner join (no table append)',
      (db) => db
          .select(users.id, users.name, pets.name)
          .from(users)
          .join(pets, on: users.id.equals(pets.ownerId)),
    );

    goldenTest(
      'explicit columns with left join',
      (db) => db
          .select(users.name, pets.name)
          .from(users)
          .leftJoin(pets, on: users.id.equals(pets.ownerId)),
    );

    goldenTest(
      'aggregate + join + group by + order by',
      (db) => db
          .select(users.id, users.name, count(pets.id))
          .from(users)
          .join(pets, on: users.id.equals(pets.ownerId))
          .groupBy(users.id)
          .orderBy({users.name: Order.asc}),
    );

    goldenTest(
      'nullable column projects as nullable',
      (db) => db.select(users.name, users.deletedAt).from(users),
    );
  });

  group('Delete', () {
    goldenTest('all rows', (db) => db.delete(from: users));

    goldenTest(
      'with where',
      (db) => db.delete(from: users).where(users.id.equals(1)),
    );

    goldenTest(
      'with OR filter',
      (db) => db.delete(from: users).where(
            users.name.equals('Morgan') | users.name.equals('Alex'),
          ),
    );

    goldenTest(
      'with returning',
      (db) => db.delete(from: users).where(users.id.equals(1)).returning(),
    );

    goldenTest(
      'with limit',
      (db) => db.delete(from: users).where(users.age.greaterThan(0)).limit(10),
    );
  });
}
