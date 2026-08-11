import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

import 'package:raindrop_postgres_example/schemas/pets.dart';
import 'package:raindrop_postgres_example/schemas/users.dart';

class ExampleLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {
    stdout.writeln('\x1B[90m$query => $values\x1B[0m');
  }
}

void main() async {
  final connection = await Connection.open(
    Endpoint(
      host: 'localhost',
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
  final db = Raindrop(
    PostgresDelegate(connection),
    logger: ExampleLogger(),
  );

  await db.execute('''
CREATE TABLE IF NOT EXISTS users (
  id INTEGER NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  deleted_at INTEGER
);''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS pets (
  id INTEGER NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  owner_id INTEGER NULL
);''');

  const testUser = User(name: 'testing');

  final emptyResult = await db.insert(into: users).values([testUser]);
  print('Inserted one but no result: $emptyResult');

  final [user] = await db.insert(into: users).values([testUser]).returning();
  print('Inserted one user: $user');

  await db.insert(into: pets).values([
    const Pet(name: 'Rex', ownerId: 1),
    const Pet(name: 'Milo', ownerId: 1),
    const Pet(name: 'Smokey', ownerId: 2),
  ]);

  final petsPerUser = await db
      .select(users.id, users.name, count(pets.id))
      .from(users)
      .join(pets, on: users.id.equals(pets.ownerId))
      .groupBy(users.id)
      .orderBy({count(pets.id): Order.desc, users.name: Order.asc});
  print('Pets per user: $petsPerUser');

  // MIN/MAX aggregates as a typed (int?, int?) tuple.
  final idRange = await db.select(min(pets.id), max(pets.id)).from(pets);
  print('Pet id range: $idRange');

  final namesAndTheirOccurrences = await db
      .select(users.name, users.name.count())
      .from(users)
      .where(users.deletedAt.isNull())
      .groupBy(users.name);
  print('Found the following names: $namesAndTheirOccurrences');

  final usersFound = await db.select().from(users).where(
        not(users.id.equals(1)) & users.name.like('%est%'),
      );
  print('users found: $usersFound');

  final updatedNames = await db
      .update(users)
      .set(users.name.to('anotherTest'))
      .where(users.id.equals(1))
      .returning();

  print('Updated to the following names: $updatedNames');

  final a = pets.as('a');
  final b = pets.as('b');
  final c = pets.as('c');
  final result = await db
      .select()
      .from(users)
      .join(a, on: users.id.equals(a.ownerId))
      .leftJoin(b, on: users.id.equals(b.ownerId))
      .rightJoin(c, on: c.id.equals(1));

  print(result);

  final softDeleted = await db
      .update(users)
      .set(users.deletedAt.to(DateTime.now()))
      .where(users.id.equals(1))
      .returning();

  print('Soft deleted the following users: $softDeleted');

  final deletedUsers = await db
      .delete(from: users)
      .where(users.name.equals('anotherTest') | users.name.equals('testing'))
      .returning();

  print('Deleted the following users: $deletedUsers');

  await Future.wait([
    () {
      return db.transaction((tx) async {
        await tx.execute('SELECT 1');
        await tx.transaction((tx2) async {
          await tx2.execute('SELECT 2');
        });
      });
    }(),
    () {
      return db.transaction((tx) {
        return tx.transaction((tx2) {
          return tx2.execute('SELECT 3');
        });
      });
    }(),
    db.execute('SELECT 4'),
  ]);

  await connection.close();
}
