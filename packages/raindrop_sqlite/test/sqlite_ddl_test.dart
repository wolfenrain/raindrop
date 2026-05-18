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
      expect(sql, startsWith('CREATE TABLE "items_raindrop_rebuild"'));
    });
  });
}
