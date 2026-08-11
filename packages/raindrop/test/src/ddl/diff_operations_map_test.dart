import 'package:raindrop/ddl.dart';
import 'package:test/test.dart';

void main() {
  final column = ColumnInfo(
    name: 'id',
    type: 'INTEGER',
    isNullable: false,
    primaryKey: true,
    autoIncrement: true,
  );
  final table = TableInfo(name: 't', columns: [column], checks: {'c': '1'});
  final index = IndexInfo(
    name: 'i',
    tableName: 't',
    columns: ['id'],
    isUnique: true,
    where: '"id" > 0',
  );

  group('serialization round trips', () {
    test('CreateTable', () {
      final restored = DiffOperation.fromMap(CreateTable(table).toMap());
      expect(restored, isA<CreateTable>());
      final create = restored as CreateTable;
      expect(create.table.name, 't');
      expect(create.table.columns, [column]);
      expect(create.table.checks, {'c': '1'});
    });

    test('DropTable', () {
      final restored = DiffOperation.fromMap(DropTable('t').toMap());
      expect(restored, isA<DropTable>());
      expect((restored as DropTable).tableName, 't');
    });

    test('CreateIndex', () {
      final restored = DiffOperation.fromMap(CreateIndex(index: index).toMap());
      expect(restored, isA<CreateIndex>());
      expect((restored as CreateIndex).index, index);
    });

    test('DropIndex', () {
      final restored = DiffOperation.fromMap(
        DropIndex('i', tableName: 't').toMap(),
      );
      expect(restored, isA<DropIndex>());
      final drop = restored as DropIndex;
      expect(drop.indexName, 'i');
      expect(drop.tableName, 't');
    });

    test('AlterTable carries every optional field', () {
      final renamed = ColumnInfo(name: 'b', type: 'TEXT', isNullable: false);
      final other = TableInfo(name: 'other', columns: [column]);
      final otherIndex = IndexInfo(
        name: 'other_idx',
        tableName: 'other',
        columns: ['id'],
      );
      final operation = AlterTable(
        oldTable: table,
        newTable: TableInfo(name: 't', columns: [column, renamed]),
        renamedColumns: {'a': 'b'},
        oldIndexes: [index],
        newIndexes: [index],
        referencedBy: [
          ReferencedBy(table: other, indexes: [otherIndex])
        ],
      );

      final restored = DiffOperation.fromMap(operation.toMap());
      expect(restored, isA<AlterTable>());
      final alter = restored as AlterTable;
      expect(alter.tableName, 't');
      expect(alter.oldTable.columns, [column]);
      expect(alter.newTable.columns, [column, renamed]);
      expect(alter.renamedColumns, {'a': 'b'});
      expect(alter.oldIndexes, [index]);
      expect(alter.newIndexes, [index]);
      expect(alter.referencedBy, hasLength(1));
      expect(alter.referencedBy.single.table.name, 'other');
      expect(alter.referencedBy.single.indexes, [otherIndex]);
    });

    test('AlterTable defaults its optional fields when absent', () {
      final operation = AlterTable(oldTable: table, newTable: table);
      final map = operation.toMap();
      expect(map.containsKey('renamedColumns'), isFalse);
      expect(map.containsKey('oldIndexes'), isFalse);
      expect(map.containsKey('newIndexes'), isFalse);
      expect(map.containsKey('referencedBy'), isFalse);

      final restored = DiffOperation.fromMap(map) as AlterTable;
      expect(restored.renamedColumns, isEmpty);
      expect(restored.oldIndexes, isEmpty);
      expect(restored.newIndexes, isEmpty);
      expect(restored.referencedBy, isEmpty);
    });
  });
}
