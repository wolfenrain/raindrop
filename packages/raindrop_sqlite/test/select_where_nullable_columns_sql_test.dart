import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

class User extends Schema<User> {
  User({
    int? id,
    required String name,
    required String favoriteGame,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name, name),
        favoriteGame =
            $.text('favoriteGame', (s) => s.favoriteGame, favoriteGame);

  final IntColumn? id;

  final TextColumn? name;

  final TextColumn? favoriteGame;

  static const $ = SchemaBuilder<User>();
}

final users = sqliteTable(
  'users',
  () => User(
    id: fakes.primaryKey(),
    name: fakes.text(),
    favoriteGame: fakes.text(),
  ),
);

void main() {
  test(
    'nullable-aware column equals filters combine with AND',
    () {
      final table = Table.get(users)! as Table<User>;
      final query = Select<User, User>(
        selecting: table,
        from: table,
        where:
            users.favoriteGame?.equals('zelda') & users.name?.equals('Morgan'),
      );

      final (sql, values) = const SQLiteDialect().translate(query);

      expect(
        sql,
        r'SELECT "id", "name", "favoriteGame" FROM "users" '
        r'WHERE "favoriteGame" = $1 AND "name" = $2',
      );
      expect(values, ['zelda', 'Morgan']);
    },
  );
}
