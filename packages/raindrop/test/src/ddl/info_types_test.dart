import 'package:raindrop/ddl.dart';
import 'package:test/test.dart';

void main() {
  test('info types compare structurally', () {
    final fk = ForeignKeyInfo(referencedTable: 't', referencedColumn: 'c');
    expect(
      fk,
      ForeignKeyInfo(referencedTable: 't', referencedColumn: 'c'),
    );
    expect(fk.hashCode, isNotNull);
    expect(
      fk,
      isNot(
        ForeignKeyInfo(
          referencedTable: 't',
          referencedColumn: 'c',
          onDelete: 'CASCADE',
        ),
      ),
    );

    final column = ColumnInfo(name: 'a', type: 'TEXT', isNullable: false);
    expect(column, ColumnInfo(name: 'a', type: 'TEXT', isNullable: false));
    expect(column.hashCode, isNotNull);

    final table = TableInfo(name: 't', columns: [column]);
    expect(table.column('a'), column);
    expect(table.column('missing'), isNull);

    // Round-trips, including a ReferencedBy without indexes.
    final restored = ReferencedBy.fromMap(
      ReferencedBy(table: table).toMap(),
    );
    expect(restored.table.column('a'), column);
    expect(restored.indexes, isEmpty);
  });
}
