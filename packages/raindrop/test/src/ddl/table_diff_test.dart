import 'package:raindrop/ddl.dart';
import 'package:test/test.dart';

ColumnInfo _column(String name, {String type = 'TEXT'}) =>
    ColumnInfo(name: name, type: type, isNullable: false);

void main() {
  group('TableDiff', () {
    test('splits adds, drops and alters', () {
      final diff = TableDiff.of(
        AlterTable(
          oldTable: TableInfo(
            name: 't',
            columns: [_column('kept'), _column('gone'), _column('changed')],
          ),
          newTable: TableInfo(
            name: 't',
            columns: [
              _column('kept'),
              _column('changed', type: 'INTEGER'),
              _column('added'),
            ],
          ),
        ),
      );

      expect(diff.addedColumns.single.name, 'added');
      expect(diff.droppedColumns.single.name, 'gone');
      expect(diff.alteredColumns.single.$1.name, 'changed');
      expect(diff.alteredColumns.single.$2.type, 'INTEGER');
    });

    test('a renamed column is neither added, dropped nor altered', () {
      final diff = TableDiff.of(
        AlterTable(
          oldTable: TableInfo(name: 't', columns: [_column('a')]),
          newTable: TableInfo(name: 't', columns: [_column('b')]),
          renamedColumns: const {'a': 'b'},
        ),
      );

      expect(diff.addedColumns, isEmpty);
      expect(diff.droppedColumns, isEmpty);
      expect(diff.alteredColumns, isEmpty);
      expect(diff.changesDefinitions, isFalse);
    });

    test('check deltas split into added, dropped and changed', () {
      final diff = TableDiff.of(
        AlterTable(
          oldTable: TableInfo(
            name: 't',
            columns: [_column('a')],
            checks: const {'kept': '1', 'gone': '2', 'changed': '3'},
          ),
          newTable: TableInfo(
            name: 't',
            columns: [_column('a')],
            checks: const {'kept': '1', 'changed': '4', 'added': '5'},
          ),
        ),
      );

      expect(diff.addedChecks, {'added': '5'});
      expect(diff.droppedChecks, {'gone': '2'});
      expect(diff.changedChecks, {'changed': ('3', '4')});
      expect(diff.changesDefinitions, isTrue);
    });

    test('a changed index is a drop plus a create', () {
      const before = IndexInfo(name: 'i', tableName: 't', columns: ['a']);
      const after =
          IndexInfo(name: 'i', tableName: 't', columns: ['a'], isUnique: true);

      final diff = TableDiff.of(
        AlterTable(
          oldTable: TableInfo(name: 't', columns: [_column('a')]),
          newTable: TableInfo(name: 't', columns: [_column('a')]),
          oldIndexes: const [before],
          newIndexes: const [after],
        ),
      );

      expect(diff.droppedIndexes.single, before);
      expect(diff.addedIndexes.single, after);
    });
  });
}
