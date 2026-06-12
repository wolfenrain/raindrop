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

// ── Negatives: must not be discovered ───────────────────────────────────────

final notATable = 42;

const plainConst = 'x';

dynamic _dynamicBooks() {
  return table('dyn_books', BookSchema.new, dialect: 'sqlite');
}

final lostToDynamic = _dynamicBooks();
