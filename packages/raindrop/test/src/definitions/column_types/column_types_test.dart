import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final items = testTable('items', _ItemSchema.new);

  group('Table column operator', () {
    test('returns the column with the given name', () {
      final t = items.$;
      expect(t['id'], same(t.columns.singleWhere((c) => c.name == 'id')));
      expect(t['label'], same(t.columns.singleWhere((c) => c.name == 'label')));
    });

    test('throws when the name is not found', () {
      final t = items.$;
      expect(() => t['missing'], throwsStateError);
    });
  });
}

class _Item {
  _Item({required this.label, this.id});

  final int? id;
  final String label;
}

class _ItemSchema extends Schema<_Item> {
  _ItemSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        label = $.text('label', (s) => s.label);

  @override
  _Item fromRow(RowReader read) => _Item(id: read(id), label: read(label)!);

  final ColumnType<int?> id;

  final ColumnType<String> label;
}
