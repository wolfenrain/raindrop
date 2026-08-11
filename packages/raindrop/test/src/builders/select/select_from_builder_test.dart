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

  group('clause chaining', () {
    test('whole-row builder chains every clause', () {
      final builder = db
          .select()
          .from(users)
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.name: Order.asc})
          .limit(2)
          .offset(1);

      expect(sqlOf(builder), stringContainsInOrder(_statementOrder));
    });

    test('projection builder chains every clause', () {
      final builder = db
          .select(users.name, users.age)
          .from(users)
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.age: Order.desc})
          .limit(2)
          .offset(0);

      expect(sqlOf(builder), stringContainsInOrder(_statementOrder));
    });

    test('single projection builder chains every clause', () {
      final builder = db
          .select(users.name)
          .from(users)
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.name: Order.desc})
          .limit(1)
          .offset(0);

      expect(sqlOf(builder), stringContainsInOrder(_statementOrder));
    });

    test('base builder chains every clause', () {
      final projected = db.select(users.name).from(users);
      final base = SelectFromBuilder<Schema<dynamic>, dynamic, String>(
        projected.executor,
        config: projected.config,
      );

      final builder = base
          .where(users.age.greaterThan(0))
          .groupBy(users.id)
          .having(count().greaterThan(0))
          .orderBy({users.name: Order.asc})
          .limit(3)
          .offset(0);

      expect(sqlOf(builder), stringContainsInOrder(_statementOrder));
    });
  });

  group('compile', () {
    test('renders distinct when asked', () {
      final builder = db.select
          .distinct(pets.ownerId)
          .from(pets)
          .orderBy({pets.ownerId: Order.asc});

      expect(sqlOf(builder), contains('SELECT DISTINCT'));
    });

    test('omits optional clauses when not asked for', () {
      final sql = sqlOf(db.select().from(users));

      expect(sql, isNot(contains('WHERE')));
      expect(sql, isNot(contains('GROUP BY')));
      expect(sql, isNot(contains('HAVING')));
      expect(sql, isNot(contains('ORDER BY')));
      expect(sql, isNot(contains('LIMIT')));
      expect(sql, isNot(contains('OFFSET')));
    });

    test('renders every clause in statement order', () {
      final sql = sqlOf(
        db
            .select(users.name)
            .from(users)
            .where(users.age.greaterThan(0))
            .groupBy(users.id)
            .having(count().greaterThan(0))
            .orderBy({users.age: Order.desc})
            .limit(2)
            .offset(1),
      );

      expect(
        sql,
        stringContainsInOrder([
          'SELECT',
          'FROM',
          'WHERE',
          'GROUP BY',
          'HAVING',
          'ORDER BY',
          'DESC',
          'LIMIT',
          'OFFSET',
        ]),
      );
    });
  });

  group('whole-row joins', () {
    /// One user row followed by one pet row, as a join produces them.
    DatabaseResult joined(List<Object?> user, List<Object?> pet) {
      return DatabaseResult(
        columns: ['id', 'name', 'age', 'id', 'owner_id', 'name'],
        rows: [
          [...user, ...pet],
        ],
        rowsAffected: 0,
        lastInsertedRowId: null,
      );
    }

    test('inner join appends the joined row', () async {
      delegate.enqueue(joined([1, 'Morgan', 30], [2, 1, 'Milo']));
      final builder = db
          .select()
          .from(users)
          .join(pets, on: users.id.equals(pets.ownerId))
          .orderBy({pets.name: Order.asc});

      expect(sqlOf(builder), contains('INNER JOIN "pets"'));
      final row = (await builder).single;
      expect(row.$1.name, 'Morgan');
      expect(row.$2.name, 'Milo');
    });

    test('left join yields null for an unmatched row', () async {
      delegate.enqueue(joined([3, 'Sam', 41], [null, null, null]));
      final rows = await db
          .select()
          .from(users)
          .leftJoin(pets, on: users.id.equals(pets.ownerId))
          .where(users.name.equals('Sam'));

      expect(rows.single.$1.name, 'Sam');
      expect(rows.single.$2, isNull);
    });

    test('right join renders', () {
      final sql = sqlOf(
        db.select().from(pets).rightJoin(
              users,
              on: users.id.equals(pets.ownerId),
            ),
      );

      expect(sql, contains('RIGHT JOIN "users"'));
    });
  });
}

class _User {
  _User({required this.name, required this.age, this.id});

  final int? id;
  final String name;
  final int age;
}

class _UserSchema extends Schema<_User> {
  _UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name),
        age = $.integer('age', (u) => u.age);

  @override
  _User fromRow(RowReader read) =>
      _User(id: read(id), name: read(name)!, age: read(age)!);

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<int> age;
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

/// The clauses every select builder must chain, in statement order.
const _statementOrder = [
  'SELECT',
  'FROM',
  'WHERE',
  'GROUP BY',
  'HAVING',
  'ORDER BY',
  'LIMIT',
  'OFFSET',
];
