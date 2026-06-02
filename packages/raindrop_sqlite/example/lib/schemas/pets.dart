import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

import 'users.dart';

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

  final IntColumn? id;

  final IntColumn ownerId;

  final TextColumn name;
}

final pets = sqliteTable(
  'pets',
  PetSchema.new,
  (table) {
    index('pets_owner').on(table.ownerId, table.id);
  },
);
