import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final db = Raindrop(TestDelegate());

  String sqlOf(Object builder) =>
      TestDialect().translate((builder as ToQuery).compile()).$1;

  /// A stand-in for a driver's row-capping clause, naming what it was handed.
  Clause probe(Table<Schema<dynamic>, dynamic> table, Filter? where) => Keyword(
        'PROBE ${table.name} ${where == null ? 'unfiltered' : 'filtered'}',
      );

  group('limitingRows', () {
    test('hands an update the table it targets and its filter', () {
      final sql = sqlOf(
        db
            .update(users)
            .set(users.age.to(23))
            .where(users.id.equals(1))
            .limitingRows(UpdateSlot.where + 1000, probe),
      );

      expect(
        sql,
        stringContainsInOrder(['UPDATE', 'WHERE', 'PROBE users filtered']),
      );
    });

    test('hands an update that was never filtered a null filter', () {
      final sql = sqlOf(
        db
            .update(users)
            .set(users.age.to(23))
            .limitingRows(UpdateSlot.where + 1000, probe),
      );

      expect(sql, contains('PROBE users unfiltered'));
    });

    test('hands a delete the table it targets and its filter', () {
      final sql = sqlOf(
        db
            .delete(from: users)
            .where(users.id.equals(1))
            .limitingRows(DeleteSlot.where + 1000, probe),
      );

      expect(
        sql,
        stringContainsInOrder(['DELETE', 'WHERE', 'PROBE users filtered']),
      );
    });

    test('replaces the core where when placed at its weight', () {
      final sql = sqlOf(
        db
            .delete(from: users)
            .where(users.id.equals(1))
            .limitingRows(DeleteSlot.where, probe),
      );

      expect(sql, contains('PROBE users filtered'));
      expect(sql, isNot(contains('WHERE "id"')));
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
