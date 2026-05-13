import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

class _Item extends Schema<_Item> {
  _Item({
    int? id,
    required String label,
  })  : id = $.integer('id', (s) => s.id, id).primaryKey(autoIncrement: true),
        label = $.text('label', (s) => s.label, label);

  final IntColumn? id;
  final TextColumn label;

  static const $ = SchemaBuilder<_Item>();
}

void main() {
  final items = sqliteTable(
    'items',
    () => _Item(
      id: fakes.primaryKey(),
      label: fakes.text(),
    ),
  );

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
