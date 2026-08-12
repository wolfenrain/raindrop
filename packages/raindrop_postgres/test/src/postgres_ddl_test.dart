import 'package:raindrop/ddl.dart';
import 'package:raindrop_postgres/src/postgres_ddl.dart';
import 'package:test/test.dart';

void main() {
  final generator = PostgresDdlGenerator();

  group('alterTable', () {
    test('column changes decompose into in-place ALTERs', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age'),
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
          renamedColumns: {'name': 'full_name'},
        ),
      );

      expect(sql, '''
ALTER TABLE "users" RENAME COLUMN "name" TO "full_name";
ALTER TABLE "users" ALTER COLUMN "age" TYPE INTEGER;
ALTER TABLE "users" ALTER COLUMN "age" SET DEFAULT 0;
ALTER TABLE "users" ALTER COLUMN "bio" SET NOT NULL;''');
    });

    test('a column becoming nullable drops its NOT NULL', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(name: 'users', columns: [_column('bio')]),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('bio', isNullable: true)],
          ),
        ),
      );

      expect(sql, 'ALTER TABLE "users" ALTER COLUMN "bio" DROP NOT NULL;');
    });

    test('a check change drops and re-adds the constraint', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'INTEGER')],
            checks: {'age_positive': '"age" > 0', 'gone': '1 = 1'},
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'INTEGER')],
            checks: {'age_positive': '"age" >= 0', 'added': '2 = 2'},
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
                foreignKey: ForeignKeyInfo(
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
                foreignKey: ForeignKeyInfo(
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
            columns: [_column('age')],
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

  group('plain statements', () {
    test('createTable renders SERIAL, defaults, checks and references', () {
      final sql = generator.generate([
        CreateTable(
          TableInfo(
            name: 'pets',
            columns: [
              _column(
                'id',
                type: 'INTEGER',
                primaryKey: true,
                autoIncrement: true,
              ),
              _column('legs', type: 'INTEGER', defaultValue: '4'),
              _column(
                'owner_id',
                type: 'INTEGER',
                foreignKey: ForeignKeyInfo(
                  referencedTable: 'owners',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                  onUpdate: 'RESTRICT',
                ),
              ),
            ],
            checks: {'has_legs': '"legs" > 0'},
          ),
        ),
        DropTable('old'),
        DropIndex('old_index', tableName: 'old'),
        CreateIndex(
          index: IndexInfo(
            name: 'pets_legs',
            tableName: 'pets',
            columns: ['legs'],
            isUnique: true,
            where: '"legs" > 2',
          ),
        ),
      ]);

      expect(sql, contains('"id" SERIAL PRIMARY KEY'));
      expect(sql, contains('"legs" INTEGER NOT NULL DEFAULT 4'));
      expect(
        sql,
        contains(
          'REFERENCES "owners"("id") ON DELETE CASCADE ON UPDATE RESTRICT',
        ),
      );
      expect(sql, contains('CONSTRAINT "has_legs" CHECK ("legs" > 0)'));
      expect(sql, contains('DROP TABLE "old";'));
      expect(sql, contains('DROP INDEX "old_index";'));
      expect(
        sql,
        contains(
          '''
CREATE UNIQUE INDEX "pets_legs" ON "pets" ("legs") WHERE "legs" > 2;''',
        ),
      );
    });

    test('index changes on an altered table render as drops and creates', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(name: 'users', columns: [_column('a')]),
          newTable: TableInfo(name: 'users', columns: [_column('a')]),
          oldIndexes: [
            IndexInfo(name: 'users_a', tableName: 'users', columns: ['a']),
          ],
          newIndexes: [
            IndexInfo(
              name: 'users_a',
              tableName: 'users',
              columns: ['a'],
              isUnique: true,
            ),
          ],
        ),
      );

      expect(sql, contains('DROP INDEX "users_a";'));
      expect(sql, contains('CREATE UNIQUE INDEX "users_a"'));
    });

    test('a default drop renders DROP DEFAULT', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('a', defaultValue: '1')],
          ),
          newTable: TableInfo(name: 'users', columns: [_column('a')]),
        ),
      );

      expect(sql, 'ALTER TABLE "users" ALTER COLUMN "a" DROP DEFAULT;');
    });

    test('dropping a foreign key without replacing it only drops', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'pets',
            columns: [
              _column(
                'owner_id',
                type: 'INTEGER',
                foreignKey: ForeignKeyInfo(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                ),
              ),
            ],
          ),
          newTable: TableInfo(
            name: 'pets',
            columns: [_column('owner_id', type: 'INTEGER')],
          ),
        ),
      );

      expect(sql, 'ALTER TABLE "pets" DROP CONSTRAINT "pets_owner_id_fkey";');
    });
  });
}

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
