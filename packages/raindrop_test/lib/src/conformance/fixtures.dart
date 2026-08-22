import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/src/test_table.dart';

/// A row of the conformance `users` table.
class User {
  /// Creates a user row.
  User({
    required this.name,
    required this.favoriteGame,
    required this.age,
    this.nickname,
    this.id,
  });

  /// The auto-incremented primary key, `null` until inserted.
  final int? id;

  /// The user's name.
  final String name;

  /// The user's favorite game.
  final String favoriteGame;

  /// The user's age.
  final int age;

  /// The user's nickname, if any.
  final String? nickname;
}

/// The schema of the conformance `users` table.
///
/// Uses only core column registrations, so it works over any driver's
/// delegate. The suite creates the backing table itself through the
/// harness's DDL generator.
class UserSchema extends Schema<User> {
  /// Creates the schema.
  UserSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name),
        favoriteGame = $.text('favoriteGame', (s) => s.favoriteGame),
        age = $.integer('age', (s) => s.age),
        nickname = $.text('nickname', (s) => s.nickname);

  @override
  User fromRow(RowReader read) => User(
        id: read(id),
        name: read(name)!,
        favoriteGame: read(favoriteGame)!,
        age: read(age)!,
        nickname: read(nickname),
      );

  /// The `id` column.
  final ColumnType<int?> id;

  /// The `name` column.
  final ColumnType<String> name;

  /// The `favoriteGame` column.
  final ColumnType<String> favoriteGame;

  /// The `age` column.
  final ColumnType<int> age;

  /// The `nickname` column.
  final ColumnType<String?> nickname;
}

/// The conformance `users` table.
final UserSchema users = testTable('users', UserSchema.new);

/// A row of the conformance `pets` table.
class Pet {
  /// Creates a pet row.
  Pet({required this.name, required this.ownerId, this.id});

  /// The auto-incremented primary key, `null` until inserted.
  final int? id;

  /// The `users` row this pet belongs to.
  final int ownerId;

  /// The pet's name.
  final String name;
}

/// The schema of the conformance `pets` table.
///
/// Uses only core column registrations, so it works over any driver's
/// delegate.
class PetSchema extends Schema<Pet> {
  /// Creates the schema.
  PetSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        ownerId = $
            .integer('owner_id', (s) => s.ownerId)
            .references(() => users.id, onDelete: ReferentialAction.cascade),
        name = $.text('name', (s) => s.name);

  @override
  Pet fromRow(RowReader read) => Pet(
        id: read(id),
        ownerId: read(ownerId)!,
        name: read(name)!,
      );

  /// The `id` column.
  final ColumnType<int?> id;

  /// The `owner_id` column.
  final ColumnType<int> ownerId;

  /// The `name` column.
  final ColumnType<String> name;
}

/// The conformance `pets` table.
final PetSchema pets = testTable('pets', PetSchema.new);
