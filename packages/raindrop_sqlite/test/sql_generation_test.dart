import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

import '_support/sql_golden.dart';

class User {
  User({
    required this.name,
    required this.favoriteGame,
    required this.age,
    this.deletedAt,
    this.id,
  });

  final int? id;
  final String name;
  final String favoriteGame;
  final int age;
  final DateTime? deletedAt;
}

class UserSchema extends Schema<User> implements User {
  UserSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name),
        favoriteGame = $.text('favoriteGame', (s) => s.favoriteGame),
        age = $.integer('age', (s) => s.age),
        deletedAt = $.dateTime('deletedAt', (s) => s.deletedAt);

  @override
  User fromRow(RowReader read) => User(
        id: read(id),
        name: read(name)!,
        favoriteGame: read(favoriteGame)!,
        age: read(age)!,
        deletedAt: read(deletedAt),
      );

  @override
  final IntColumn? id;
  @override
  final TextColumn name;
  @override
  final TextColumn favoriteGame;
  @override
  final IntColumn age;
  @override
  final DateTimeColumn? deletedAt;
}

final users = sqliteTable('users', UserSchema.new);

class Pet {
  Pet({required this.name, required this.ownerId, this.id});

  final int? id;
  final int ownerId;
  final String name;
}

class PetSchema extends Schema<Pet> implements Pet {
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

  @override
  final IntColumn? id;
  @override
  final IntColumn ownerId;
  @override
  final TextColumn name;
}

final pets = sqliteTable('pets', PetSchema.new);

void main() {
  group('Select', () {
    goldenTest('all columns', (db) => db.select().from(users));

    goldenTest(
      'single column',
      (db) => db.select(users.name.$).from(users),
    );

    goldenTest(
      'multiple columns',
      (db) => db.select(users.name.$, users.age.$).from(users),
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
      (db) => db.select(users.name.$).from(users).groupBy(users.favoriteGame.$),
    );

    goldenTest(
      'with limit',
      (db) => db.select().from(users).limit(10),
    );

    goldenTest(
      'with limit and offset',
      (db) => db.select().from(users).limit(10).offset(20),
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
