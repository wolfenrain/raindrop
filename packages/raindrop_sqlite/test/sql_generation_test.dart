import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

import '_support/sql_golden.dart';

class User extends Schema<User> {
  User({
    required String name,
    required String favoriteGame,
    required int age,
    DateTime? deletedAt,
    int? id,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name, name),
        favoriteGame =
            $.text('favoriteGame', (s) => s.favoriteGame, favoriteGame),
        age = $.integer('age', (s) => s.age, age),
        deletedAt = $.dateTime('deletedAt', (s) => s.deletedAt, deletedAt);

  final IntColumn? id;
  final TextColumn name;
  final TextColumn favoriteGame;
  final IntColumn age;
  final DateTimeColumn? deletedAt;

  static const $ = SchemaBuilder<User>();
}

final users = sqliteTable(
  'users',
  () => User(
    id: fakes.primaryKey(),
    name: fakes.text(),
    favoriteGame: fakes.text(),
    age: fakes.integer(),
    deletedAt: fakes.dateTime(),
  ),
);

class Pet extends Schema<Pet> {
  Pet({
    required String name,
    required int ownerId,
    int? id,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        ownerId = $.integer('owner_id', (s) => s.ownerId, ownerId),
        name = $.text('name', (s) => s.name, name);

  final IntColumn? id;
  final IntColumn ownerId;
  final TextColumn name;

  static const $ = SchemaBuilder<Pet>();
}

final pets = sqliteTable(
  'pets',
  () => Pet(
    id: fakes.primaryKey(),
    ownerId: fakes.integer(),
    name: fakes.text(),
  ),
);

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
      (db) => db
          .insert(into: users)
          .values([User(name: 'Morgan', favoriteGame: 'zelda', age: 30)])
          .returning(),
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
      (db) =>
          db.delete(from: users).where(users.age.greaterThan(18)).limit(10),
    );
  });
}
