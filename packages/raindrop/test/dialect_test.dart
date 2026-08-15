import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final rows = testTable('rows', _RowSchema.new);
  final dialect = TestDialect();
  final db = Raindrop(TestDelegate());

  String translate(Object builder) =>
      dialect.translate((builder as ToQuery<dynamic, dynamic>).compile()).$1;

  group('withClause', () {
    test('slots a clause into a select statement', () {
      final builder = db.select().from(rows).withClause(
            SelectSlot.offset + 500,
            (_) => Keyword('-- trailing'),
            SelectFromBuilder.new,
          );

      expect(translate(builder), endsWith('-- trailing'));
    });

    test('slots a clause into a pre-values insert statement', () {
      final builder = db
          .insert(into: rows)
          .withClause<InsertValuesBuilder<_RowSchema, _Row, void>>(
            InsertSlot.verb + 500,
            (_) => Keyword('OR IGNORE'),
            InsertValuesBuilder.new,
          )
          .values([_Row(name: 'a')]);

      expect(translate(builder), contains('INSERT OR IGNORE'));
    });

    test('slots a clause into an insert statement with values', () {
      final builder =
          db.insert(into: rows).values([_Row(name: 'a')]).withClause(
        InsertSlot.verb + 500,
        (_) => Keyword('OR REPLACE'),
        InsertWithValuesBuilder.new,
      );

      expect(translate(builder), contains('INSERT OR REPLACE'));
    });

    test('slots a clause into an update statement', () {
      final builder = db.update(rows).set(rows.name.to('b')).withClause(
            UpdateSlot.where + 500,
            (_) => Keyword('-- trailing'),
            UpdateWhereBuilder.new,
          );

      expect(translate(builder), endsWith('-- trailing'));
    });

    test('slots a clause into a delete statement', () {
      final builder =
          db.delete(from: rows).where(rows.name.equals('a')).withClause(
                DeleteSlot.where + 500,
                (_) => Keyword('-- trailing'),
                DeleteWhereBuilder.new,
              );

      expect(translate(builder), endsWith('-- trailing'));
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
