import 'package:raindrop/ddl.dart';
import 'package:test/test.dart';

void main() {
  group('ForeignKeyInfo', () {
    test('round-trips through toMap/fromMap with actions', () {
      final fk = ForeignKeyInfo(
        referencedTable: 'owners',
        referencedColumn: 'id',
        onDelete: 'CASCADE',
        onUpdate: 'SET NULL',
      );
      final map = fk.toMap();
      expect(map, {
        'referencedTable': 'owners',
        'referencedColumn': 'id',
        'onDelete': 'CASCADE',
        'onUpdate': 'SET NULL',
      });
      expect(ForeignKeyInfo.fromMap(map), fk);
    });

    test('omits absent actions from its map', () {
      final fk = ForeignKeyInfo(referencedTable: 't', referencedColumn: 'c');
      final map = fk.toMap();
      expect(map.containsKey('onDelete'), isFalse);
      expect(map.containsKey('onUpdate'), isFalse);
      expect(ForeignKeyInfo.fromMap(map), fk);
    });
  });

  group('ColumnInfo', () {
    test('round-trips a fully specified column, foreign key included', () {
      final column = ColumnInfo(
        name: 'owner_id',
        type: 'INTEGER',
        isNullable: true,
        defaultValue: '0',
        foreignKey: ForeignKeyInfo(
          referencedTable: 'owners',
          referencedColumn: 'id',
          onDelete: 'CASCADE',
        ),
      );
      expect(ColumnInfo.fromMap(column.toMap()), column);
    });

    test('defaults the flags when the map omits them', () {
      final column = ColumnInfo.fromMap({
        'name': 'a',
        'type': 'TEXT',
        'isNullable': false,
      });
      expect(column.primaryKey, isFalse);
      expect(column.autoIncrement, isFalse);
      expect(column.defaultValue, isNull);
      expect(column.foreignKey, isNull);
    });
  });

  group('IndexInfo', () {
    final index = IndexInfo(
      name: 'i',
      tableName: 't',
      columns: ['a', 'b'],
      isUnique: true,
      where: '"a" IS NULL',
    );

    test('round-trips through toMap/fromMap', () {
      final map = index.toMap();
      expect(map, {
        'name': 'i',
        'tableName': 't',
        'columns': ['a', 'b'],
        'isUnique': true,
        'where': '"a" IS NULL',
      });
      expect(IndexInfo.fromMap(map), index);
    });

    test('omits an absent where and defaults isUnique', () {
      final plain = IndexInfo(name: 'i', tableName: 't', columns: ['a']);
      final map = plain.toMap();
      expect(map.containsKey('where'), isFalse);
      final restored = IndexInfo.fromMap({
        'name': 'i',
        'tableName': 't',
        'columns': ['a'],
      });
      expect(restored, plain);
      expect(restored.isUnique, isFalse);
    });

    test('equality is structural, including column order', () {
      expect(
        index,
        IndexInfo(
          name: 'i',
          tableName: 't',
          columns: ['a', 'b'],
          isUnique: true,
          where: '"a" IS NULL',
        ),
      );
      expect(index.hashCode, isNotNull);

      IndexInfo variant({
        String name = 'i',
        String tableName = 't',
        List<String> columns = const ['a', 'b'],
        bool isUnique = true,
        String? where = '"a" IS NULL',
      }) {
        return IndexInfo(
          name: name,
          tableName: tableName,
          columns: columns,
          isUnique: isUnique,
          where: where,
        );
      }

      expect(index, isNot(variant(name: 'other')));
      expect(index, isNot(variant(tableName: 'other')));
      expect(index, isNot(variant(isUnique: false)));
      expect(index, isNot(variant(where: null)));
      expect(index, isNot(variant(columns: ['a'])));
      expect(index, isNot(variant(columns: ['b', 'a'])));
      expect(index, isNot(equals('not an index')));
    });
  });
}
