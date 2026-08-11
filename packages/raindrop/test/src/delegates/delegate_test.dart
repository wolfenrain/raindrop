import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final rows = testTable('rows', _RowSchema.new);
  final delegate = TestDelegate();
  final db = Raindrop(delegate);
  final dialect = TestDialect();

  String translate(Object builder) =>
      dialect.translate((builder as ToQuery<dynamic, dynamic>).compile()).$1;

  group('Delegate', () {
    test('insert creates a builder writing into the table', () {
      final builder = delegate.insert<_Row>(db, rows.$);

      final sql = translate(builder.values([_Row(name: 'a')]));
      expect(sql, startsWith('INSERT INTO "rows"'));
    });

    test('select creates a builder over the selection', () {
      final builder = delegate.select<_Row>(db, rows);

      expect(builder, isA<SelectBuilder<_Row>>());
    });

    test('update creates a builder targeting the table', () {
      final builder = delegate.update<_Row>(db, rows.$);

      final sql = translate(builder.set(rows.name.to('b')));
      expect(sql, startsWith('UPDATE "rows"'));
    });

    test('delete creates a builder removing from the table', () {
      final builder = delegate.delete<_Row>(db, rows.$);

      expect(translate(builder), startsWith('DELETE FROM "rows"'));
    });

    test('carries the dialect it was created with', () {
      expect(delegate.dialect, isA<TestDialect>());
    });
  });
}

class _Row {
  _Row({required this.name, this.id});

  final int? id;
  final String name;
}

class _RowSchema extends Schema<_Row> {
  _RowSchema(super.$)
      : id = $.integer('id', (r) => r.id).primaryKey(autoIncrement: true),
        name = $.text('name', (r) => r.name);

  final ColumnType<int?> id;
  final ColumnType<String> name;

  @override
  _Row fromRow(RowReader read) => _Row(id: read(id), name: read(name));
}
