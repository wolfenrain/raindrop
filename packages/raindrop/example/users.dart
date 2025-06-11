import 'package:raindrop/raindrop.dart';

class User extends Schema<User> {
  User({
    required String email,
    int? id,
  })  : id = builder.primaryKey('id', (s) => s.id, value: id),
        email = builder.text('email', (s) => s.email, value: email);

  final PrimaryKey id;

  final TextColumn email;

  static const builder = SchemaBuilder<User>();
}

final users = table(
  'users',
  () => User(
    id: fakes.primaryKey(),
    email: fakes.text(),
  ),
);
