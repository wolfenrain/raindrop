import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/raindrop_cli.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaSnapshot', () {
    final snapshot = SchemaSnapshot(
      version: SchemaSnapshot.currentVersion,
      dialect: 'sqlite',
      id: SchemaSnapshot.generateId(),
      prevId: SchemaSnapshot.nullUuid,
      tables: {
        'users': TableSnapshot(
          name: 'users',
          columns: {
            'id': ColumnSnapshot(
              name: 'id',
              type: 'INTEGER',
              isNullable: false,
              primaryKey: true,
              autoIncrement: true,
            ),
            'ref': ColumnSnapshot(
              name: 'ref',
              type: 'INTEGER',
              isNullable: true,
              defaultValue: '0',
              foreignKey: ForeignKeySnapshotRef(
                referencedTable: 'other',
                referencedColumn: 'id',
                onDelete: 'CASCADE',
                onUpdate: 'RESTRICT',
              ),
            ),
          },
          checks: {'c': '1 = 1'},
        ),
      },
      indexes: {
        'users_ref': IndexSnapshot(
          name: 'users_ref',
          tableName: 'users',
          columns: ['ref'],
          isUnique: true,
          where: '"ref" IS NOT NULL',
        ),
      },
    );

    test('round-trips through JSON', () {
      final restored = SchemaSnapshot.fromJson(snapshot.toJson());
      expect(restored.toJson(), snapshot.toJson());
      expect(restored.tables['users']!.columns['ref']!.foreignKey!.onDelete,
          'CASCADE');
      expect(restored.indexes['users_ref']!.where, '"ref" IS NOT NULL');
    });

    test('generateId is a v4 uuid, and unique', () {
      final id = SchemaSnapshot.generateId();
      expect(
        id,
        matches(
          '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      );
      expect(SchemaSnapshot.generateId(), isNot(id));
    });

    test('copyWith replaces only the identity', () {
      final copy = snapshot.copyWith(id: 'x', prevId: 'y');
      expect(copy.id, 'x');
      expect(copy.prevId, 'y');
      expect(copy.tables, same(snapshot.tables));
    });

    test('save and load round-trip through disk, load returns null when absent',
        () async {
      final dir = Directory.systemTemp.createTempSync('snapshot_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'nested', 's.json');

      expect(await SchemaSnapshot.load(path), isNull);
      await snapshot.save(path);
      final loaded = await SchemaSnapshot.load(path);
      expect(loaded!.toJson(), snapshot.toJson());
    });

    test('copyWith without arguments keeps the identity', () {
      expect(snapshot.copyWith().id, snapshot.id);
      expect(snapshot.copyWith().prevId, snapshot.prevId);
    });

    test('equal foreign keys collapse in a set', () {
      ForeignKeySnapshotRef fk() => ForeignKeySnapshotRef(
            referencedTable: 'users',
            referencedColumn: 'id',
            onDelete: 'CASCADE',
          );

      expect({fk(), fk()}, hasLength(1));
      expect(fk().hashCode, fk().hashCode);
    });

    test('equal indexes collapse in a set', () {
      IndexSnapshot index() => IndexSnapshot(
            name: 'users_email',
            tableName: 'users',
            columns: ['email'],
            isUnique: true,
          );

      expect({index(), index()}, hasLength(1));
      expect(index().hashCode, index().hashCode);
    });

    test('column equality is structural', () {
      final a = ColumnSnapshot(name: 'a', type: 'TEXT', isNullable: false);
      final b = ColumnSnapshot(name: 'a', type: 'TEXT', isNullable: false);
      final c = ColumnSnapshot(name: 'a', type: 'TEXT', isNullable: true);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('index equality is order-sensitive on columns', () {
      final a = IndexSnapshot(name: 'i', tableName: 't', columns: ['x', 'y']);
      final b = IndexSnapshot(name: 'i', tableName: 't', columns: ['y', 'x']);
      expect(a, isNot(b));
    });
  });
}
