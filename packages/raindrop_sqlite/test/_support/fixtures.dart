import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

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

final UserSchema users = sqliteTable('users', UserSchema.new);

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

final PetSchema pets = sqliteTable('pets', PetSchema.new);

/// A logger that stays quiet during tests.
class SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
