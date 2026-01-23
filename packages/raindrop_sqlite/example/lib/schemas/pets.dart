import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

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

final pets = sqliteTable(
  'pets',
  () => Pet(
    id: fakes.primaryKey(),
    userId: fakes.integer(),
    name: fakes.text(),
  ),
  (table) {
    index('pets_owner').on(table.ownerId, table.id);
  },
);
