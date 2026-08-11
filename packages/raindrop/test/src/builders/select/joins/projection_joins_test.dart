import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  late TestDelegate delegate;
  late Raindrop db;

  setUp(() {
    delegate = TestDelegate();
    db = Raindrop(delegate);
  });

  String sqlOf(Object builder) =>
      TestDialect().translate((builder as ToQuery).compile()).$1;

  group('ProjectionJoins', () {
    test('join keeps the projection intact', () async {
      delegate.enqueue(
        DatabaseResult(
          columns: ['name', 'name'],
          rows: [
            ['Morgan', 'Milo'],
            ['Morgan', 'Rex'],
          ],
          rowsAffected: 0,
          lastInsertedRowId: null,
        ),
      );
      final builder = db
          .select(users.name, pets.name)
          .from(users)
          .join(pets, on: users.id.equals(pets.ownerId))
          .orderBy({pets.name: Order.asc});

      expect(sqlOf(builder), contains('INNER JOIN "pets"'));
      expect(await builder, [('Morgan', 'Milo'), ('Morgan', 'Rex')]);
    });

    test('leftJoin registers without altering the projection', () async {
      delegate.enqueue(
        DatabaseResult(
          columns: ['name', 'count'],
          rows: [
            ['Alex', 0],
            ['Morgan', 2],
          ],
          rowsAffected: 0,
          lastInsertedRowId: null,
        ),
      );
      final builder = db
          .select(users.name, count(pets.id))
          .from(users)
          .leftJoin(pets, on: users.id.equals(pets.ownerId))
          .groupBy(users.id)
          .orderBy({users.name: Order.asc});

      expect(sqlOf(builder), contains('LEFT JOIN "pets"'));
      expect(await builder, [('Alex', 0), ('Morgan', 2)]);
    });

    test('rightJoin registers without altering the projection', () {
      final sql = sqlOf(
        db
            .select(pets.name)
            .from(pets)
            .rightJoin(users, on: users.id.equals(pets.ownerId)),
      );

      expect(sql, contains('RIGHT JOIN "users"'));
    });
  });
}

class _User {
  _User({required this.name, this.id});

  final int? id;
  final String name;
}

class _UserSchema extends Schema<_User> {
  _UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name);

  @override
  _User fromRow(RowReader read) => _User(id: read(id), name: read(name)!);

  final ColumnType<int?> id;
  final ColumnType<String> name;
}

class _Pet {
  _Pet({required this.ownerId, required this.name, this.id});

  final int? id;
  final int ownerId;
  final String name;
}

class _PetSchema extends Schema<_Pet> {
  _PetSchema(super.$)
      : id = $.integer('id', (p) => p.id).primaryKey(autoIncrement: true),
        ownerId = $.integer('owner_id', (p) => p.ownerId),
        name = $.text('name', (p) => p.name);

  @override
  _Pet fromRow(RowReader read) =>
      _Pet(id: read(id), ownerId: read(ownerId)!, name: read(name)!);

  final ColumnType<int?> id;
  final ColumnType<int> ownerId;
  final ColumnType<String> name;
}

final _UserSchema users = testTable('users', _UserSchema.new);
final _PetSchema pets = testTable('pets', _PetSchema.new);
