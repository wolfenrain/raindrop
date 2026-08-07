import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop_postgres/src/postgres_ddl.dart';
import 'package:test/test.dart';

ColumnInfo _column(
  String name, {
  String type = 'TEXT',
  bool isNullable = false,
  bool primaryKey = false,
  bool autoIncrement = false,
  String? defaultValue,
  ForeignKeyInfo? foreignKey,
}) {
  return ColumnInfo(
    name: name,
    type: type,
    isNullable: isNullable,
    primaryKey: primaryKey,
    autoIncrement: autoIncrement,
    defaultValue: defaultValue,
    foreignKey: foreignKey,
  );
}

void main() {
  late ReceivePort port;
  late PostgresDdlGenerator generator;

  setUp(() {
    port = ReceivePort();
    generator = PostgresDdlGenerator(port.sendPort);
  });

  tearDown(() {
    generator.dispose();
    port.close();
  });

  group('alterTable', () {
    test('column changes decompose into in-place ALTERs', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age', type: 'TEXT'),
              _column('bio', isNullable: true),
              _column('name'),
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age', type: 'INTEGER', defaultValue: '0'),
              _column('bio'),
              _column('full_name'),
            ],
          ),
          renamedColumns: const {'name': 'full_name'},
        ),
      );

      expect(sql, '''
ALTER TABLE "users" RENAME COLUMN "name" TO "full_name";
ALTER TABLE "users" ALTER COLUMN "age" TYPE INTEGER;
ALTER TABLE "users" ALTER COLUMN "age" SET DEFAULT 0;
ALTER TABLE "users" ALTER COLUMN "bio" SET NOT NULL;''');
    });

    test('a check change drops and re-adds the constraint', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'INTEGER')],
            checks: const {'age_positive': '"age" > 0', 'gone': '1 = 1'},
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'INTEGER')],
            checks: const {'age_positive': '"age" >= 0', 'added': '2 = 2'},
          ),
        ),
      );

      expect(sql, '''
ALTER TABLE "users" DROP CONSTRAINT "gone";
ALTER TABLE "users" DROP CONSTRAINT "age_positive";
ALTER TABLE "users" ADD CONSTRAINT "added" CHECK (2 = 2);
ALTER TABLE "users" ADD CONSTRAINT "age_positive" CHECK ("age" >= 0);''');
    });

    test('a foreign key change goes through the default constraint name', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'pets',
            columns: [
              _column(
                'owner_id',
                type: 'INTEGER',
                foreignKey: const ForeignKeyInfo(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                ),
              ),
            ],
          ),
          newTable: TableInfo(
            name: 'pets',
            columns: [
              _column(
                'owner_id',
                type: 'INTEGER',
                foreignKey: const ForeignKeyInfo(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
            ],
          ),
        ),
      );

      expect(sql, '''
ALTER TABLE "pets" DROP CONSTRAINT "pets_owner_id_fkey";
ALTER TABLE "pets" ADD CONSTRAINT "pets_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE;''');
    });

    test('the referencing closure is ignored', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'TEXT')],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'INTEGER')],
          ),
          referencedBy: [
            ReferencedBy(
              table: TableInfo(
                name: 'pets',
                columns: [_column('owner_id', type: 'INTEGER')],
              ),
            ),
          ],
        ),
      );

      expect(sql, isNot(contains('__new_')));
      expect(sql, isNot(contains('pets')));
    });

    test('a primary key change throws with guidance', () {
      expect(
        () => generator.alterTable(
          AlterTable(
            oldTable: TableInfo(
              name: 'users',
              columns: [_column('id', type: 'INTEGER')],
            ),
            newTable: TableInfo(
              name: 'users',
              columns: [_column('id', type: 'INTEGER', primaryKey: true)],
            ),
          ),
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('generate --empty'),
          ),
        ),
      );
    });
  });
}
