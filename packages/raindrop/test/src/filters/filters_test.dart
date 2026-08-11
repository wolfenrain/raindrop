import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final rows = testTable('rows', _RowSchema.new);
  final dialect = TestDialect();
  final db = Raindrop(TestDelegate());

  /// Renders [filter] as a single-table predicate with literals inlined.
  String render(Filter filter) => FilterClause(filter, singleTable: true)
      .render(LiteralRenderContext(dialect));

  group('Filter', () {
    test('and combines two filters', () {
      final combined = rows.name.equals('a') & rows.name.equals('b');

      expect(combined, isA<LogicalFilter>());
      expect(render(combined), '"name" = \'a\' AND "name" = \'b\'');
    });

    test('or combines two filters', () {
      final combined = rows.name.equals('a') | rows.name.equals('b');

      expect(combined, isA<LogicalFilter>());
      expect(render(combined), '"name" = \'a\' OR "name" = \'b\'');
    });

    test('and with null keeps the left filter', () {
      final left = rows.name.equals('a');

      expect(left & null, same(left));
      expect(left | null, same(left));
    });
  });

  group('FilterX', () {
    test('a null left side yields the right side unchanged', () {
      Filter? left;
      final right = rows.name.equals('a');

      expect(left & right, same(right));
      expect(left | right, same(right));
    });

    test('a non-null left side combines as usual', () {
      final left = rows.name.equals('a');
      final right = rows.name.equals('b');

      expect(FilterX<Filter?>(left) & right, isA<LogicalFilter>());
      expect(FilterX<Filter?>(left) | right, isA<LogicalFilter>());
    });

    test('null on both sides stays null', () {
      Filter? left;

      expect(left & null, isNull);
      expect(left | null, isNull);
    });
  });

  group('Raw as filter', () {
    test('and combines a raw fragment with another filter', () {
      final combined = raw('a = 1') & raw('b = 2');

      expect(render(combined), 'a = 1 AND b = 2');
    });

    test('or combines a raw fragment with another filter', () {
      final combined = raw('a = 1') | raw('b = 2');

      expect(render(combined), 'a = 1 OR b = 2');
    });

    test('and or with null keeps the raw fragment', () {
      final fragment = raw('a = 1');

      expect(fragment & null, same(fragment));
      expect(fragment | null, same(fragment));
    });
  });

  group('SQL', () {
    test('toString joins the chunks', () {
      expect(SQL([RawSQL('a'), 1]).toString(), 'a 1');
    });

    test('function renders comma separated arguments', () {
      final sql = SQL.function('COALESCE', [rows.name, rows.name]);

      expect(
        ExpressionClause(sql, singleTable: true)
            .render(LiteralRenderContext(dialect)),
        'COALESCE("name", "name")',
      );
    });
  });

  group('RawSQL', () {
    test('toString is the raw fragment', () {
      expect(RawSQL('IS NULL').toString(), 'IS NULL');
    });
  });

  group('exists', () {
    test('renders EXISTS around the subquery', () {
      final filter = exists(db.select().from(rows));

      final sql = render(filter);
      expect(sql, startsWith('EXISTS (SELECT'));
      expect(sql, endsWith(')'));
    });

    test('not inverts an exists filter', () {
      final filter = not(exists(db.select().from(rows)));

      expect(render(filter), startsWith('NOT'));
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
