import 'dart:io';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

// import 'schemas/items.dart';
import 'package:raindrop_sqlite_example/schemas/pets.dart';
import 'package:raindrop_sqlite_example/schemas/users.dart';

class ExampleLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {
    stdout.writeln('\x1B[90m$query => $values\x1B[0m');
  }
}

void main() async {
  final db = Raindrop(
    SQLiteDelegate.memory(),
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

  await db.ensureOpen();
  final testUser = User(name: 'testing');

  final emptyResult = await db.insert(into: users).values([testUser]);
  print('Inserted one but no result: $emptyResult');

  final [user] = await db.insert(into: users).values([testUser]).returning();
  print('Inserted one user: $user');

  // final test0 = await db.select().from(users);
  // print(test0);

  // final test1 = await db.select(users.name.$).fromX(users);
  // print(test1);

  // final test2 = await db.select(users.name.$, users.name.count()).fromX(users);
  // print(test2);

  // final test3 =
  //     await db.select(users.id.$, users.name.$, users.id.$).fromX(users);
  // print(test3);

  final namesAndTheirOccurrences = await db
      .select(users.name.$, users.name.count())
      .from(users)
      .where(users.deletedAt.isNull())
      .groupBy(users.name.$);
  print('Found the following names: $namesAndTheirOccurrences');

  final usersFound = await db.select().from(users).where(
        not(users.id.equals(1)) & users.name.like('%est%'),
      );
  print('users found: $usersFound');

  final updatedNames = await db
      .update(users)
      .set(
        users.name.to('anotherTest'),
        users.id.to(0),
        users.name.to('g'),
      )
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

  // final publicUser = (users.name, users.id).$;
  // final publicItem = (items.id, items.label).$;
  // final [((userName, userId), (itemsId, itemsLabel))] = await db
  //     .select((publicUser, publicItem).$)
  //     .from(users)
  //     .join(items, on: items.userId.equals(users.id));
  // print(userName);

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

  await db.close();
}
