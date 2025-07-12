import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class Pet extends Schema<Pet> {
  Pet({
    required String name,
    int? userId,
    int? id,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        ownerId = $.integer('owner_id', (s) => s.ownerId, userId),
        name = $.text('name', (s) => s.name, name);

  final IntColumn? id;

  final IntColumn ownerId;

  final TextColumn name;

  static const $ = SchemaBuilder<Pet>();
}

final posts = table(
  'pets',
  () => Pet(
    id: fakes.primaryKey(),
    userId: fakes.integer(),
    name: fakes.text(),
  ),
);
