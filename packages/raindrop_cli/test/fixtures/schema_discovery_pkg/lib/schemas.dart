// Fixture sources for `test/schema_runtime_test.dart`.
//
// Tests copy this file into a temp directory with a generated `pubspec.yaml`
// (a pubspec here would be picked up by the repo workspace incorrectly).
library;

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

// ── sqliteTable: recognized via Schema subtype (not method name alone) ───────

class Pet {
  const Pet({this.id, required this.name});

  final int? id;
  final String name;
}

class PetSchema extends Schema<Pet> {
  PetSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name);

  @override
  Pet fromRow(RowReader read) => Pet(
        id: read(id),
        name: read(name)!,
      );

  final ColumnType<int?> id;
  final ColumnType<String> name;
}

final pets = sqliteTable('pets', PetSchema.new);

// ── Custom wrapper: static type is still BookSchema <: Schema ───────────────

class Book {
  const Book({required this.title});

  final String title;
}

class BookSchema extends Schema<Book> {
  BookSchema(super.$) : title = $.text('title', (s) => s.title);

  @override
  Book fromRow(RowReader read) => Book(title: read(title)!);

  final ColumnType<String> title;
}

BookSchema _registerBooks() {
  return table('books', BookSchema.new, dialect: 'sqlite');
}

final books = _registerBooks();

// ── Another indirection: public function name unrelated to raindrop ──────

class Widget {
  const Widget({required this.n});

  final int n;
}

class WidgetSchema extends Schema<Widget> {
  WidgetSchema(super.$) : n = $.integer('n', (s) => s.n);

  @override
  Widget fromRow(RowReader read) => Widget(n: read(n)!);

  final ColumnType<int> n;
}

WidgetSchema totallyUnrelatedFactory() {
  return table('widgets', WidgetSchema.new, dialect: 'sqlite');
}

final widgets = totallyUnrelatedFactory();

// ── Dialect filtering: postgres table excluded from sqlite snapshots ─────────

class PgOnly {
  const PgOnly({required this.n});

  final int n;
}

class PgOnlySchema extends Schema<PgOnly> {
  PgOnlySchema(super.$) : n = $.integer('n', (s) => s.n);

  @override
  PgOnly fromRow(RowReader read) => PgOnly(n: read(n)!);

  final ColumnType<int> n;
}

final pgOnly = table('pg_only', PgOnlySchema.new, dialect: 'postgres');

// ── Index metadata: partial where + duplicate names across tables ───────────

class Owner {
  const Owner({this.id});

  final int? id;
}

class OwnerSchema extends Schema<Owner> {
  OwnerSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true);

  @override
  Owner fromRow(RowReader read) => Owner(id: read(id));

  final ColumnType<int?> id;
}

final owners = sqliteTable('owners', OwnerSchema.new);

class Item {
  const Item({this.id, required this.ownerId, this.deletedAt});

  final int? id;
  final int ownerId;
  final int? deletedAt;
}

class ItemSchema extends Schema<Item> {
  ItemSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        ownerId = $
            .integer('owner_id', (s) => s.ownerId)
            .references(
              () => owners.id,
              onDelete: ReferentialAction.cascade,
              onUpdate: ReferentialAction.setNull,
            ),
        deletedAt = $.integer('deleted_at', (s) => s.deletedAt);

  @override
  Item fromRow(RowReader read) => Item(
        id: read(id),
        ownerId: read(ownerId)!,
        deletedAt: read(deletedAt),
      );

  final ColumnType<int?> id;
  final ColumnType<int> ownerId;
  final ColumnType<int?> deletedAt;
}

final items = sqliteTable(
  'items',
  ItemSchema.new,
  (table) {
    index('shared_idx', where: table.deletedAt.isNull()).on(table.ownerId);
  },
);

class Tag {
  const Tag({required this.label});

  final String label;
}

class TagSchema extends Schema<Tag> {
  TagSchema(super.$) : label = $.text('label', (s) => s.label);

  @override
  Tag fromRow(RowReader read) => Tag(label: read(label)!);

  final ColumnType<String> label;
}

final tags = sqliteTable(
  'tags',
  TagSchema.new,
  (table) {
    index('shared_idx').on(table.label);
  },
);

// ── Negatives: must not be discovered ───────────────────────────────────────

final notATable = 42;

const plainConst = 'x';

dynamic _dynamicBooks() {
  return table('dyn_books', BookSchema.new, dialect: 'sqlite');
}

final lostToDynamic = _dynamicBooks();
