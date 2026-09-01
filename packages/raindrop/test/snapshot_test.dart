import 'package:raindrop/snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaSnapshot', () {
    final snapshot = SchemaSnapshot(
      dialect: 'sqlite',
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

    test('round-trips through a map', () {
      final restored = SchemaSnapshot.fromMap(snapshot.toMap());
      expect(restored.toMap(), snapshot.toMap());
      expect(
        restored.tables['users']!.columns['ref']!.foreignKey!.onDelete,
        'CASCADE',
      );
      expect(restored.indexes['users_ref']!.where, '"ref" IS NOT NULL');
    });

    group('converting to DDL info', () {
      test('the default moves from "default" to defaultValue', () {
        final column = snapshot.tables['users']!.columns['ref']!.toColumnInfo();
        expect(column.defaultValue, '0');
      });

      test('columns become an ordered list', () {
        final table = snapshot.tables['users']!.toTableInfo();
        expect([for (final column in table.columns) column.name], [
          'id',
          'ref',
        ]);
      });

      test('checks are carried over', () {
        expect(snapshot.tables['users']!.toTableInfo().checks, {'c': '1 = 1'});
      });

      test('a foreign key keeps its actions', () {
        final column = snapshot.tables['users']!.columns['ref']!.toColumnInfo();
        expect(column.foreignKey!.referencedTable, 'other');
        expect(column.foreignKey!.onDelete, 'CASCADE');
        expect(column.foreignKey!.onUpdate, 'RESTRICT');
      });

      test('an index keeps uniqueness and its predicate', () {
        final index = snapshot.indexes['users_ref']!.toIndexInfo();
        expect(index.isUnique, isTrue);
        expect(index.where, '"ref" IS NOT NULL');
      });

      test('the snapshot converts every table and index at once', () {
        expect(snapshot.tableInfos, hasLength(1));
        expect(snapshot.indexInfos, hasLength(1));
      });
    });

    group('equality', () {
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

    group('strict parsing', () {
      Map<String, dynamic> document() => snapshot.toMap();

      Matcher failsWith(String fragment) => throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains(fragment),
            ),
          );

      void expectRejected(Map<String, dynamic> data, String fragment) {
        expect(() => SchemaSnapshot.fromMap(data), failsWith(fragment));
      }

      Map<String, dynamic> table(Map<String, dynamic> data) =>
          (data['tables'] as Map<String, dynamic>)['users']
              as Map<String, dynamic>;

      Map<String, dynamic> column(Map<String, dynamic> data, String name) =>
          (table(data)['columns'] as Map<String, dynamic>)[name]
              as Map<String, dynamic>;

      test('rejects an unknown schema key', () {
        expectRejected(
          document()..['foreignKeys'] = <String, dynamic>{},
          '"foreignKeys"',
        );
      });

      test('rejects a missing schema key', () {
        expectRejected(document()..remove('dialect'), '"dialect"');
      });

      test('rejects an unknown table key', () {
        final data = document();
        table(data)['renamed'] = true;
        expectRejected(data, 'table "users"');
      });

      test('rejects a column key written under another name', () {
        // The casing an older format used: ignoring it would silently read
        // the column as autoIncrement: false, a phantom schema change.
        final data = document();
        column(data, 'id')
          ..remove('autoIncrement')
          ..['autoincrement'] = true;
        expectRejected(data, '"autoincrement"');
      });

      test('rejects a missing column key', () {
        final data = document();
        column(data, 'id').remove('isNullable');
        expectRejected(data, '"isNullable"');
      });

      test('rejects an unknown foreign key key', () {
        final data = document();
        (column(data, 'ref')['foreignKey'] as Map<String, dynamic>)['onDrop'] =
            'CASCADE';
        expectRejected(data, 'a foreign key reference');
      });

      test('rejects an unknown index key', () {
        final data = document();
        ((data['indexes'] as Map<String, dynamic>)['users_ref']
            as Map<String, dynamic>)['method'] = 'btree';
        expectRejected(data, 'index "users_ref"');
      });
    });
  });
}
