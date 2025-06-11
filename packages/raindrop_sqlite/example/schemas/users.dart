import 'package:raindrop/raindrop.dart';

class User extends Schema<User> {
  User({
    required String name,
    int? id,
  })  : id = _builder.primaryKey('id', (s) => s.id, value: id),
        name = _builder.text('name', (s) => s.name, value: name);

  final PrimaryKey id;

  final TextColumn name;

  static const _builder = SchemaBuilder<User>();
}

final users = table(
  'users',
  () => User(
    id: fakes.primaryKey(),
    name: fakes.text(),
  ),
);
