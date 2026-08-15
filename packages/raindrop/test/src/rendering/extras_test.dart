import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final db = Raindrop(TestDelegate());

  String sqlOf(Object builder) =>
      TestDialect().translate((builder as ToQuery).compile()).$1;

  /// A stand-in for a driver's clause, naming what the config held at
  /// compile time.
  Clause probe(QueryConfig config) => Keyword(
        'PROBE ${(config.table ?? config.from ?? config.into)!.name} '
        '${config.where == null ? 'unfiltered' : 'filtered'}',
      );

  group('withClause', () {
    test('builds from the config as it finally stands', () {
      final sql = sqlOf(
        db
            .update(users)
            .set(users.age.to(23))
            .where(users.id.equals(1))
            .withClause(UpdateSlot.where + 1000, probe, UpdateWhereBuilder.new),
      );

      expect(
        sql,
        stringContainsInOrder(['UPDATE', 'WHERE', 'PROBE users filtered']),
      );
    });

    test('sees a filter added after it', () {
      final sql = sqlOf(
        db
            .update(users)
            .set(users.age.to(23))
            .withClause(UpdateSlot.where + 1000, probe, UpdateWhereBuilder.new)
            .where(users.id.equals(1)),
      );

      expect(sql, contains('PROBE users filtered'));
    });

    test('hands a statement that was never filtered a null filter', () {
      final sql = sqlOf(
        db
            .update(users)
            .set(users.age.to(23))
            .withClause(UpdateSlot.where + 1000, probe, UpdateWhereBuilder.new),
      );

      expect(sql, contains('PROBE users unfiltered'));
    });

    test('replaces the core where when placed at its weight', () {
      final sql = sqlOf(
        db
            .delete(from: users)
            .where(users.id.equals(1))
            .withClause(DeleteSlot.where, probe, DeleteWhereBuilder.new),
      );

      expect(sql, contains('PROBE users filtered'));
      expect(sql, isNot(contains('WHERE "id"')));
    });

    test('continues the chain as the builder create names', () {
      final sealed = db
          .update(users)
          .set(users.age.to(23))
          .where(users.id.equals(1))
          .withClause(UpdateSlot.where, probe, UpdateLimitedBuilder.new);

      expect(sealed, isA<UpdateLimitedBuilder<dynamic, dynamic, dynamic>>());
      expect(sqlOf(sealed), contains('PROBE users filtered'));

      final sealedDelete = db
          .delete(from: users)
          .where(users.id.equals(1))
          .withClause(DeleteSlot.where, probe, DeleteLimitedBuilder.new);

      expect(
        sealedDelete,
        isA<DeleteLimitedBuilder<dynamic, dynamic, dynamic>>(),
      );
      expect(
        sqlOf(sealedDelete),
        stringContainsInOrder(['DELETE FROM', 'PROBE users filtered']),
      );
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

      final inserted = await Raindrop(delegate).insert(into: users).values([
        _User(name: 'Robin', age: 22)
      ]).withClause<InsertWithValuesBuilder<_UserSchema, _User, _User>>(
        InsertSlot.body + 5000,
        (config) => Keyword('PROBE ${config.into!.name}'),
        InsertWithValuesBuilder.new,
      );

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
