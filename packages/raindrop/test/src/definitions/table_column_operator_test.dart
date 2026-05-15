import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

class _Item {
  _Item({required this.label, this.id});

  final int? id;
  final String label;
}

class _ItemSchema extends Schema<_Item> implements _Item {
  _ItemSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        label = $.text('label', (s) => s.label);

  @override
  _Item fromRow(RowReader read) => _Item(id: read(id), label: read(label)!);

  @override
  final IntColumn? id;

  @override
  final TextColumn label;
}

void main() {
  final items = sqliteTable('items', _ItemSchema.new);

  group('Table column operator', () {
    test('returns the column with the given name', () {
      final t = Table.get(items)!;
      expect(t['id'], same(t.columns.singleWhere((c) => c.name == 'id')));
      expect(t['label'], same(t.columns.singleWhere((c) => c.name == 'label')));
    });

    test('throws when the name is not found', () {
      final t = Table.get(items)!;
      expect(() => t['missing'], throwsStateError);
    });
  });
}
