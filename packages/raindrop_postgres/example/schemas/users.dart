import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

class User extends Schema<User> {
  User({
    required String name,
    DateTime? deletedAt,
    int? id,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name, name),
        deletedAt = $.dateTime('deleted_at', (s) => s.deletedAt, deletedAt);

  final IntColumn? id;

  final TextColumn name;

  // TODO: if this is not nullable it should be an error on it's definition.
  final DateTimeColumn? deletedAt;

  static const $ = SchemaBuilder<User>();
}

final users = table(
  'users',
  () => User(
    id: fakes.primaryKey(),
    name: fakes.text(),
    deletedAt: fakes.dateTime(),
  ),
);
