import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final db = Raindrop(TestDelegate());

  String sqlOf(Object builder) =>
      TestDialect().translate((builder as ToQuery).compile()).$1;

  /// A stand-in for a driver's row-yielding clause, naming the table it was
  /// resolved with.
  Clause probe(Table<Schema<dynamic>, dynamic> table) =>
      Keyword('PROBE ${table.name}');

  group('yieldingRows', () {
    test('renders the clause after an insert body', () {
      final sql = sqlOf(
        db.insert(into: users).values([
          _User(name: 'Robin', age: 22),
        ]).yieldingRows(InsertSlot.body + 5000, probe),
      );

      expect(sql, stringContainsInOrder(['INSERT', 'VALUES', 'PROBE users']));
    });

    test('renders the clause after an update where', () {
      final sql = sqlOf(
        db
            .update(users)
            .set(users.age.to(23))
            .where(users.id.equals(1))
            .yieldingRows(UpdateSlot.where + 5000, probe),
      );

      expect(sql, stringContainsInOrder(['UPDATE', 'WHERE', 'PROBE users']));
    });

    test('renders the clause after a delete where', () {
      final sql = sqlOf(
        db
            .delete(from: users)
            .where(users.id.equals(1))
            .yieldingRows(DeleteSlot.where + 5000, probe),
      );

      expect(sql, stringContainsInOrder(['DELETE', 'WHERE', 'PROBE users']));
    });

    test('re-types the write so rows decode through the schema', () async {
      final delegate = TestDelegate()
        ..enqueue(
          DatabaseResult(
            columns: ['id', 'name', 'age'],
            rows: [
              [1, 'Robin', 22],
            ],
            rowsAffected: 1,
            lastInsertedRowId: 1,
          ),
        );

      final inserted = await Raindrop(delegate).insert(into: users).values(
        [_User(name: 'Robin', age: 22)],
      ).yieldingRows(InsertSlot.body + 5000, probe);

      expect(inserted.single.id, 1);
      expect(inserted.single.name, 'Robin');
      expect(inserted.single.age, 22);
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

final _UserSchema users = testTable('users', _UserSchema.new);
