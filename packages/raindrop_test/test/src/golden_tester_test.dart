import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/conformance.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final golden = GoldenTester(dialect: TestDialect());

  group('select', () {
    golden
      ..test('all columns', (db) => db.select().from(users))
      ..test(
        'with where clause',
        (db) => db.select(users.name).from(users).where(users.age.equals(21)),
      )
      ..test(
        'with limit and offset',
        (db) => db.select(users.name).from(users).limit(10).offset(5),
      );
  });

  group('insert', () {
    golden.test(
      'a row',
      (db) => db.insert(into: pets).values([
        Pet(name: 'Rex', ownerId: 1),
      ]),
    );
  });

  group('update', () {
    golden.test(
      'a column with a filter',
      (db) => db
          .update(users)
          .set(users.name.to('Robin'))
          .where(users.id.equals(1)),
    );
  });

  group('delete', () {
    golden.test(
      'with a filter',
      (db) => db.delete(from: pets).where(pets.ownerId.equals(1)),
    );
  });
}
