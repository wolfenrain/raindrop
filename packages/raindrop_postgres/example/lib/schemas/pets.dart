import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

import 'package:raindrop_postgres_example/schemas/users.dart';

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
        ownerId: read(ownerId),
        name: read(name),
      );

  final ColumnType<int?> id;

  final ColumnType<int> ownerId;

  final ColumnType<String> name;
}

final PetSchema pets = postgresTable('pets', PetSchema.new);
