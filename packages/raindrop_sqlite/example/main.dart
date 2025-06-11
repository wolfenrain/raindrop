import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

import 'schemas/items.dart';
import 'schemas/users.dart';

import 'utils.dart';

void main() async {
  final db = Raindrop(SQLiteDelegate.open('example.db'));

  await db.execute('''
CREATE TABLE IF NOT EXISTS users (
  id INTEGER NOT NULL PRIMARY KEY,
  name TEXT NOT NULL
);''');

  await db.execute('''
CREATE TABLE IF NOT EXISTS items (
  id INTEGER NOT NULL PRIMARY KEY,
  label TEXT NOT NULL,
  user_id INTEGER NULL
);''');

  await db.ensureOpen();

  final testUser = User(name: 'testing');

  final emptyResult = await db.insert(into: users).values([testUser]);
  print('Inserted one but no result: $emptyResult');

  final [user] = await db.insert(into: users).values([testUser]).returning();
  print('Inserted one user: $user');

  final result = await db
      .select((users.name.$, users.name.count()).$)
      .from(users)
      .where(not(users.name.isNull()))
      .groupBy(users.name.$);
  print('Found the following names: $result');

  final usersFound = await db.select().from(users).where(
        not(users.id.equals(1)) & users.name.like('%est%'),
      );
  print('users found: $usersFound');

  final updatedNames = await db
      .update(users)
      .set(users.name.set('anotherTest'))
      .where(users.id.equals(1))
      .returning();

  print('Updated to the following names: $updatedNames');

  // final publicUser = (users.name, users.id).$;
  // final publicItem = (items.id, items.label).$;
  // final [((userName, userId), (itemsId, itemsLabel))] = await db
  //     .select((publicUser, publicItem).$)
  //     .from(users)
  //     .join(items, on: items.userId.equals(users.id));
  // print(userName);

  final deletedUsers = await db
      .delete(from: users)
      .where(users.name.equals('anotherTest') | users.name.equals('testing'))
      .returning();

  print('Deleted the following users: $deletedUsers');

  await db.close();
}
