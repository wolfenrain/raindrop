import 'package:raindrop/ddl.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  const generator = TestDdlGenerator();

  group('TestDdlGenerator', () {
    test('renders a create table, if-not-exists included', () {
      const table = TableInfo(
        name: 'things',
        columns: [
          ColumnInfo(
            name: 'id',
            type: 'INTEGER',
            isNullable: false,
            primaryKey: true,
          ),
          ColumnInfo(name: 'label', type: 'TEXT', isNullable: true),
        ],
      );

      expect(
        generator.createTable(table),
        'CREATE TABLE "things" (\n'
        '  "id" INTEGER PRIMARY KEY NOT NULL,\n'
        '  "label" TEXT\n'
        ');',
      );
      expect(
        generator.createTable(table, ifNotExists: true),
        startsWith('CREATE TABLE IF NOT EXISTS "things"'),
      );
    });

    test('renders drops and indexes', () {
      expect(generator.dropTable('things'), 'DROP TABLE "things";');
      expect(generator.dropIndex('things_label'), 'DROP INDEX "things_label";');

      const index = IndexInfo(
        name: 'things_label',
        tableName: 'things',
        columns: ['label'],
        isUnique: true,
      );
      expect(
        generator.createIndex(index),
        'CREATE UNIQUE INDEX "things_label" ON "things" ("label");',
      );
      expect(
        generator.createIndex(index, ifNotExists: true),
        'CREATE UNIQUE INDEX IF NOT EXISTS "things_label" ON "things" '
        '("label");',
      );
    });

    test('refuses table changes', () {
      const operation = AlterTable(
        oldTable: TableInfo(name: 't', columns: []),
        newTable: TableInfo(name: 't', columns: []),
      );
      expect(() => generator.alterTable(operation), throwsUnsupportedError);
    });

    test('maps column types', () {
      const column = ColumnInfo(name: 'n', type: 'BLOB', isNullable: false);
      expect(generator.getColumnType(column), 'BLOB');
    });
  });
}
