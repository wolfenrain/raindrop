import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class Item extends Schema<Item> {
  Item({
    required String label,
    int? userId,
    int? id,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        userId = $.integer('user_id', (s) => s.userId, userId),
        label = $.text('label', (s) => s.label, label);

  final IntColumn? id;

  final IntColumn userId;

  final TextColumn label;

  static const $ = SchemaBuilder<Item>();
}

final items = table(
  'items',
  () => Item(
    id: fakes.primaryKey(),
    userId: fakes.integer(),
    label: fakes.text(),
  ),
);
