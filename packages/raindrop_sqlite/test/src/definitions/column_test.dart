import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../_support/fixtures.dart';

void main() {
  late Database database;
  late Raindrop db;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: _SilentLogger());
    await db.execute(
      '''
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, "favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)''',
    );
    await db.insert(into: users).values([
      User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
      User(name: 'Alex', favoriteGame: 'tetris', age: 28),
      User(name: 'Sam', favoriteGame: 'doom', age: 41),
    ]);
  });

  tearDown(() => database.close());

  test('column nullable, alias and toString', () async {
    final column = users.$['name'];
    expect(column.nullable.isNullable, isTrue);
    expect(column.toString(), contains('name'));

    final aliased = await db.select(users.name.as('n')).from(users).first;
    expect(aliased, 'Morgan');
  });
}

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
