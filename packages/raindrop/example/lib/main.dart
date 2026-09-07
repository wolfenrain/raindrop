import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';

// A schema maps a row to your own type. Column handles are fields, so every
// query built from them is typed.
class User {
  const User({required this.name, this.id});

  final int? id;

  final String name;

  @override
  String toString() => 'User(id: $id, name: $name)';
}

class UserSchema extends Schema<User> {
  UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name);

  final ColumnType<int?> id;

  final ColumnType<String> name;

  @override
  User fromRow(RowReader read) => User(id: read(id), name: read(name));
}

class Pet {
  const Pet({required this.name, required this.ownerId, this.id});

  final int? id;

  final int ownerId;

  final String name;

  @override
  String toString() => 'Pet(id: $id, ownerId: $ownerId, name: $name)';
}

class PetSchema extends Schema<Pet> {
  PetSchema(super.$)
      : id = $.integer('id', (p) => p.id).primaryKey(autoIncrement: true),
        ownerId = $
            .integer('owner_id', (p) => p.ownerId)
            .references(() => users.id, onDelete: ReferentialAction.cascade),
        name = $.text('name', (p) => p.name);

  final ColumnType<int?> id;

  final ColumnType<int> ownerId;

  final ColumnType<String> name;

  @override
  Pet fromRow(RowReader read) =>
      Pet(id: read(id), ownerId: read(ownerId), name: read(name));
}

// A driver's table function tags the table with its dialect.
final UserSchema users = sqliteTable('users', UserSchema.new);
final PetSchema pets = sqliteTable('pets', PetSchema.new);

// In an application these come from `raindrop_cli`, which diffs the schemas
// above into SQL. Here the first migration is written by hand.
const migrations = [
  Migration('0000_initial', '''
CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "name" TEXT NOT NULL
);
CREATE TABLE "pets" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "owner_id" INTEGER NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL
);'''),
];

Future<void> main() async {
  // Hand `Raindrop` your driver's delegate. Each driver's README shows its
  // own connection setup.
  final db = Raindrop(SQLiteDelegate(sqlite3.openInMemory()));

  // Apply the migrations that are still pending.
  await migrate(db, migrations);

  // Writes use the same typed handles. `returning()` yields the stored rows
  // as your own type.
  final [alex, sam] = await db.insert(into: users).values([
    const User(name: 'Alex'),
    const User(name: 'Sam'),
  ]).returning();
  print('Inserted $alex and $sam');

  await db.insert(into: pets).values([
    Pet(name: 'Rex', ownerId: alex.id!),
    Pet(name: 'Milo', ownerId: alex.id!),
    Pet(name: 'Smokey', ownerId: sam.id!),
  ]);

  // Select nothing and you get your row type back, a `List<User>`.
  final byName = await db.select().from(users).where(users.name.equals('Alex'));
  print('Users named Alex: $byName');

  // Select columns and you get a record of exactly those columns, here a
  // `List<(String, int)>`.
  final petsPerUser = await db
      .select(users.name, count(pets.id))
      .from(users)
      .join(pets, on: users.id.equals(pets.ownerId))
      .groupBy(users.id)
      .having(count(pets.id).greaterThan(1))
      .orderBy({users.name: Order.asc});
  print('Users with more than one pet: $petsPerUser');

  // Subqueries are typed the same way.
  final owners = await db.select(users.name).from(users).where(
        exists(db.select().from(pets).where(users.id.equals(pets.ownerId))),
      );
  print('Users that own a pet: $owners');

  // A transaction runs its body against a transactional executor. A throw
  // rolls it back.
  await db.transaction((tx) async {
    final [robin] = await tx.insert(into: users).values([
      const User(name: 'Robin'),
    ]).returning();
    await tx.insert(into: pets).values([
      Pet(name: 'Nibbles', ownerId: robin.id!),
    ]);
  });

  await db
      .update(users)
      .set(users.name.to('Alexandra'))
      .where(users.id.equals(alex.id));

  // The delete cascades to Rex and Milo through the foreign key.
  await db.delete(from: users).where(users.name.equals('Alexandra'));
  print('Remaining pets: ${await db.select().from(pets)}');
}
