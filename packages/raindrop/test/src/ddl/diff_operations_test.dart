import 'package:raindrop/ddl.dart';
import 'package:test/test.dart';

void main() {
  group('DiffOperation', () {
    test('fromMap rejects an unknown type', () {
      expect(
        () => DiffOperation.fromMap({'type': 'nonsense'}),
        throwsArgumentError,
      );
    });

    test('describe() covers every operation', () {
      final index =
          IndexInfo(name: 'i', tableName: 't', columns: ['a'], isUnique: true);
      expect(
        CreateTable(TableInfo(name: 't', columns: [])).describe(),
        'Create table "t"',
      );
      expect(DropTable('t').describe(), 'Drop table "t"');
      expect(
        CreateIndex(index: index).describe(),
        'Create unique index "i" on table "t"',
      );
      expect(
        DropIndex('i', tableName: 't').describe(),
        'Drop index "i" on table "t"',
      );
      expect(
        AlterTable(
          oldTable: TableInfo(
            name: 't',
            columns: [
              ColumnInfo(name: 'gone', type: 'TEXT', isNullable: false),
              ColumnInfo(name: 'old', type: 'TEXT', isNullable: false),
            ],
            checks: {'dropped': '1'},
          ),
          newTable: TableInfo(
            name: 't',
            columns: [
              ColumnInfo(name: 'renamed', type: 'TEXT', isNullable: false),
              ColumnInfo(name: 'added', type: 'TEXT', isNullable: true),
            ],
            checks: {'added_check': '2'},
          ),
          renamedColumns: {'old': 'renamed'},
          newIndexes: [index],
        ).describe(),
        '''
Alter table "t" (rename column "old" to "renamed", add column "added", drop column "gone", add check "added_check", drop check "dropped", add index "i")''',
      );
    });
  });
}
