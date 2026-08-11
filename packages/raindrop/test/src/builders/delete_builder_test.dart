import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final db = Raindrop(TestDelegate());

  String sqlOf(Object builder) =>
      TestDialect().translate((builder as ToQuery).compile()).$1;

  group('delete', () {
    test('without a where clause renders no WHERE', () {
      expect(sqlOf(db.delete(from: users)), isNot(contains('WHERE')));
    });

    test('a delete-all builder applies a seeded where clause', () {
      final all = DeleteAllBuilder<_UserSchema, _User, void>(
        db,
        config: QueryConfig.from({
          #from: users.$,
          #where: users.id.equals(1),
        }),
      );

      expect(sqlOf(all), contains('WHERE'));
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
