import 'package:raindrop/raindrop.dart';

class Item extends Schema<Item> {
  Item({
    required String label,
    int? userId,
    int? id,
  })  : id = _builder.primaryKey('id', (s) => s.id, value: id),
        userId = _builder.integer('user_id', (s) => s.userId, value: userId),
        label = _builder.text('label', (s) => s.label, value: label);

  final PrimaryKey id;

  final IntColumn userId;

  final TextColumn label;

  static const _builder = SchemaBuilder<Item>();
}

final items = table(
  'items',
  () => Item(
    id: fakes.primaryKey(),
    userId: fakes.integer(),
    label: fakes.text(),
  ),
);
