import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop_sqlite/src/sqlite_ddl.dart';
import 'package:test/test.dart';

void main() {
  late SQLiteDdlGenerator generator;

  setUp(() {
    final receivePort = ReceivePort();
    generator = SQLiteDdlGenerator(receivePort.sendPort);
  });

  group('alterColumn', () {
    test('backfills NULLs before rebuild when becoming NOT NULL', () {
      const oldColumn = ColumnInfo(
        name: 'score',
        type: 'INTEGER',
        isNullable: true,
      );
      const newColumn = ColumnInfo(
        name: 'score',
        type: 'INTEGER',
        isNullable: false,
      );
      const tableColumns = [newColumn];

      final sql = generator.alterColumn(
        'items',
        oldColumn,
        newColumn,
        tableColumns,
      );

      expect(
        sql,
        startsWith(
          'UPDATE "items" SET "score" = 0 WHERE "score" IS NULL;\n'
          'CREATE TABLE "items_raindrop_rebuild"',
        ),
      );
      expect(sql, contains('INSERT INTO "items_raindrop_rebuild"'));
      expect(sql, contains('DROP TABLE "items"'));
      expect(sql, contains('ALTER TABLE "items_raindrop_rebuild" RENAME TO "items"'));
    });

    test('uses explicit DEFAULT for backfill when provided', () {
      const oldColumn = ColumnInfo(
        name: 'status',
        type: 'INTEGER',
        isNullable: true,
      );
      const newColumn = ColumnInfo(
        name: 'status',
        type: 'INTEGER',
        isNullable: false,
        defaultValue: '1',
      );
      const tableColumns = [newColumn];

      final sql = generator.alterColumn(
        'items',
        oldColumn,
        newColumn,
        tableColumns,
      );

      expect(
        sql,
        startsWith(
          'UPDATE "items" SET "status" = 1 WHERE "status" IS NULL;',
        ),
      );
    });

    test('uses random ids for TEXT primary keys without DEFAULT', () {
      const oldColumn = ColumnInfo(
        name: 'id',
        type: 'TEXT',
        isNullable: true,
        primaryKey: true,
      );
      const newColumn = ColumnInfo(
        name: 'id',
        type: 'TEXT',
        isNullable: false,
        primaryKey: true,
      );
      const tableColumns = [newColumn];

      final sql = generator.alterColumn(
        'users',
        oldColumn,
        newColumn,
        tableColumns,
      );

      expect(
        sql,
        startsWith(
          'UPDATE "users" SET "id" = lower(hex(randomblob(8))) '
          'WHERE "id" IS NULL;',
        ),
      );
    });

    test('omits backfill when column stays nullable', () {
      const oldColumn = ColumnInfo(
        name: 'note',
        type: 'TEXT',
        isNullable: true,
      );
      const newColumn = ColumnInfo(
        name: 'note',
        type: 'TEXT',
        isNullable: true,
        defaultValue: "''",
      );
      const tableColumns = [newColumn];

      final sql = generator.alterColumn(
        'items',
        oldColumn,
        newColumn,
        tableColumns,
      );

      expect(sql, isNot(contains('UPDATE')));
      expect(sql, startsWith('PRAGMA foreign_keys=OFF;'));
      expect(sql, contains('CREATE TABLE "items_raindrop_rebuild"'));
      expect(sql, endsWith('PRAGMA foreign_keys=ON;'));
    });

    test('disables foreign keys during rebuild and re-enables after', () {
      const oldColumn = ColumnInfo(
        name: 'score',
        type: 'INTEGER',
        isNullable: true,
      );
      const newColumn = ColumnInfo(
        name: 'score',
        type: 'INTEGER',
        isNullable: false,
      );
      const tableColumns = [newColumn];

      final sql = generator.alterColumn(
        'items',
        oldColumn,
        newColumn,
        tableColumns,
      );

      expect(sql, contains('PRAGMA foreign_keys=OFF;'));
      expect(sql, contains('DROP TABLE "items";'));
      expect(sql, endsWith('PRAGMA foreign_keys=ON;'));
      expect(
        sql.indexOf('PRAGMA foreign_keys=OFF;'),
        lessThan(sql.indexOf('DROP TABLE "items";')),
      );
      expect(
        sql.indexOf('ALTER TABLE "items_raindrop_rebuild" RENAME TO "items";'),
        lessThan(sql.indexOf('PRAGMA foreign_keys=ON;')),
      );
    });

    test('inserts by explicit column name, not positional SELECT *', () {
      // Simulates a table whose on-disk physical column order (via prior
      // `ALTER TABLE ADD COLUMN`s) no longer matches the schema's declared
      // order in `tableColumns` -- a positional `SELECT *` would shuffle
      // these into the wrong slots on rebuild.
      const oldColumn = ColumnInfo(
        name: 'age',
        type: 'INTEGER',
        isNullable: true,
      );
      const newColumn = ColumnInfo(
        name: 'age',
        type: 'INTEGER',
        isNullable: false,
      );
      const tableColumns = [
        ColumnInfo(name: 'age', type: 'INTEGER', isNullable: false),
        ColumnInfo(name: 'name', type: 'TEXT', isNullable: true),
      ];

      final sql = generator.alterColumn(
        'users',
        oldColumn,
        newColumn,
        tableColumns,
      );

      expect(sql, isNot(contains('SELECT * FROM')));
      expect(
        sql,
        contains(
          'INSERT INTO "users_raindrop_rebuild" ("age", "name") '
          'SELECT "age", "name" FROM "users";',
        ),
      );
    });

    test('recreates indexes dropped by table rebuild before re-enabling FKs', () {
      const oldColumn = ColumnInfo(
        name: 'id',
        type: 'INTEGER',
        isNullable: true,
        primaryKey: true,
      );
      const newColumn = ColumnInfo(
        name: 'id',
        type: 'INTEGER',
        isNullable: false,
        primaryKey: true,
      );
      const tableColumns = [newColumn];
      const indexes = [
        IndexInfo(
          name: 'users.id_unique',
          tableName: 'users',
          columns: ['id'],
          isUnique: true,
        ),
      ];

      final sql = generator.alterColumn(
        'users',
        oldColumn,
        newColumn,
        tableColumns,
        indexes: indexes,
      );

      expect(
        sql,
        contains(
          'CREATE UNIQUE INDEX "users.id_unique" ON "users" ("id");',
        ),
      );
      expect(
        sql.indexOf('CREATE UNIQUE INDEX "users.id_unique"'),
        lessThan(sql.indexOf('PRAGMA foreign_keys=ON;')),
      );
    });
  });

  group('generate', () {
    test('collapses multiple AlterColumns on the same table to one rebuild', () {
      const finalColumns = [
        ColumnInfo(name: 'name', type: 'TEXT', isNullable: false),
        ColumnInfo(
          name: 'age',
          type: 'INTEGER',
          isNullable: false,
          defaultValue: '0',
        ),
      ];

      final sql = generator.generate([
        const AlterColumn(
          'users',
          ColumnInfo(name: 'name', type: 'TEXT', isNullable: true),
          ColumnInfo(name: 'name', type: 'TEXT', isNullable: false),
          finalColumns,
        ),
        const AlterColumn(
          'users',
          ColumnInfo(name: 'age', type: 'INTEGER', isNullable: true),
          ColumnInfo(
            name: 'age',
            type: 'INTEGER',
            isNullable: false,
            defaultValue: '0',
          ),
          finalColumns,
        ),
      ]);

      expect(sql.split('DROP TABLE "users";'), hasLength(2));
      expect(sql, contains('UPDATE "users" SET "name" ='));
      expect(sql, contains('UPDATE "users" SET "age" = 0'));
      expect(sql, contains('"name" TEXT NOT NULL'));
      expect(sql, contains('"age" INTEGER NOT NULL DEFAULT 0'));
    });
  });
}
