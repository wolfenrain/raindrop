// Fixture sources for `test/schema_runtime_test.dart`.
//
// Tests copy this file into a temp directory with a generated `pubspec.yaml`
// (a pubspec here would be picked up by the repo workspace incorrectly).
library;

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

// ── sqliteTable: recognized via Schema subtype (not method name alone) ───────

class Pet extends Schema<Pet> {
  Pet({int? id}) : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true);
  final IntColumn? id;
  static const $ = SchemaBuilder<Pet>();
}

final pets = sqliteTable(
  'pets',
  () => Pet(id: fakes.primaryKey()),
);

// ── Custom wrapper: static type is still Book <: Schema ─────────────────────

class Book extends Schema<Book> {
  Book() : title = $.text('title', (s) => s.title, 'x');
  final TextColumn title;
  static const $ = SchemaBuilder<Book>();
}

Book _registerBooks() {
  return table(
    'books',
    () => Book(),
    dialect: 'sqlite',
  );
}

final books = _registerBooks();

// ── Another indirection: public function name unrelated to raindrop ──────────

class Widget extends Schema<Widget> {
  Widget() : n = $.integer('n', (s) => s.n, 0);
  final IntColumn n;
  static const $ = SchemaBuilder<Widget>();
}

Widget totallyUnrelatedFactory() {
  return table('widgets', () => Widget(), dialect: 'sqlite');
}

final widgets = totallyUnrelatedFactory();

// ── Negatives: must not be discovered ───────────────────────────────────────

final notATable = 42;

const plainConst = 'x';

dynamic _dynamicBooks() {
  return table('dyn_books', () => Book(), dialect: 'sqlite');
}

final lostToDynamic = _dynamicBooks();
