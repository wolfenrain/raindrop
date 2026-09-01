import 'package:raindrop/ddl.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:raindrop_test/src/conformance/fixture_operations.dart';
import 'package:test/test.dart';

void main() {
  group('fixtureCreateTableOperations', () {
    final operations = fixtureCreateTableOperations(const TestDialect());

    TableInfo tableNamed(String name) => operations
        .firstWhere((operation) => operation.table.name == name)
        .table;

    test('covers every fixture table', () {
      expect(
        [for (final operation in operations) operation.table.name],
        containsAll(['users', 'pets']),
      );
    });

    test('carries the table-level check', () {
      expect(tableNamed('users').checks, {
        'users_age_positive': contains('age'),
      });
    });

    test('carries the foreign key', () {
      final ownerId = tableNamed('pets')
          .columns
          .firstWhere((column) => column.name == 'owner_id');
      expect(ownerId.foreignKey!.referencedTable, 'users');
      expect(ownerId.foreignKey!.onDelete, 'CASCADE');
    });

    test('carries the auto-incrementing primary key', () {
      final id = tableNamed('users')
          .columns
          .firstWhere((column) => column.name == 'id');
      expect(id.primaryKey, isTrue);
      expect(id.autoIncrement, isTrue);
    });
  });
}
