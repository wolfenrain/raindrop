import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

class User {
  const User({required this.name, this.deletedAt, this.id});

  final int? id;

  final String name;

  final DateTime? deletedAt;

  @override
  String toString() => 'User(id: $id, name: $name, deletedAt: $deletedAt)';
}

class UserSchema extends Schema<User> {
  UserSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name),
        deletedAt = $.dateTime('deleted_at', (s) => s.deletedAt);

  @override
  User fromRow(RowReader read) => User(
        id: read(id),
        name: read(name),
        deletedAt: read(deletedAt),
      );

  final ColumnType<int?> id;

  final ColumnType<String> name;

  final ColumnType<DateTime?> deletedAt;
}

final UserSchema users = sqliteTable('users', UserSchema.new);
