import 'dart:typed_data';

import 'package:raindrop/dialect.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

class _NoLiteralDialect extends SqlDialect {
  const _NoLiteralDialect();

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '?';

  @override
  String escapeLiteral(Object? value) =>
      throw ArgumentError.value(value, 'value', 'nothing renders here');
}

class _Row {
  _Row({required this.name, required this.hits, this.deletedAt});

  final String name;
  final int hits;
  final int? deletedAt;
}

class _RowSchema extends Schema<_Row> {
  _RowSchema(super.$)
      : name = $.text('name', (r) => r.name),
        hits = $.integer('hits', (r) => r.hits),
        deletedAt = $.integer('deleted_at', (r) => r.deletedAt);

  final ColumnType<String> name;
  final ColumnType<int> hits;
  final ColumnType<int?> deletedAt;

  @override
  _Row fromRow(RowReader read) => _Row(
        name: read(name),
        hits: read(hits),
        deletedAt: read(deletedAt),
      );
}

void main() {
  final rows = sqliteTable('rows', _RowSchema.new);
  const dialect = SQLiteDialect();

  /// Renders as a schema-level predicate would: one table, no binds.
  String render(Filter filter) => FilterClause(filter, singleTable: true)
      .render(LiteralRenderContext(dialect));

  group('escapeLiteral', () {
    test('renders the domain filters actually produce', () {
      expect(dialect.escapeLiteral(null), 'NULL');
      expect(dialect.escapeLiteral(1), '1');
      expect(dialect.escapeLiteral(-1), '-1');
      expect(dialect.escapeLiteral(1.5), '1.5');
      expect(dialect.escapeLiteral('ok'), "'ok'");
    });

    test('doubles an embedded quote rather than ending the literal', () {
      expect(dialect.escapeLiteral("it's"), "'it''s'");
      expect(dialect.escapeLiteral("' OR 1=1 --"), "''' OR 1=1 --'");
    });

    test('booleans render as SQLite integers', () {
      expect(dialect.escapeLiteral(true), '1');
      expect(dialect.escapeLiteral(false), '0');
    });

    test("SQLite writes blobs as X'..'", () {
      expect(
        dialect.escapeLiteral(Uint8List.fromList([0, 15, 255])),
        "X'000fff'",
      );
    });

    test('a dialect owns every case, with nothing to fall back on', () {
      const nothing = _NoLiteralDialect();
      for (final value in [null, 1, 'a', true, Uint8List(1)]) {
        expect(() => nothing.escapeLiteral(value), throwsArgumentError);
      }
    });

    test('an unrenderable value throws rather than guessing', () {
      expect(
        () => dialect.escapeLiteral(DateTime.utc(2026)),
        throwsArgumentError,
      );
      expect(() => dialect.escapeLiteral(double.nan), throwsArgumentError);
      expect(() => dialect.escapeLiteral(double.infinity), throwsArgumentError);
      expect(() => dialect.escapeLiteral([1, 2]), throwsArgumentError);
    });
  });

  group('LiteralRenderContext', () {
    test('inlines instead of binding, and binds nothing', () {
      final context = LiteralRenderContext(dialect);
      final sql =
          FilterClause(rows.hits.equals(3), singleTable: true).render(context);

      expect(sql, '"hits" = 3');
      expect(sql, isNot(contains('?')));
      expect(context.values, isEmpty);
    });

    test('the default context still binds', () {
      final context = RenderContext(dialect);
      final sql =
          FilterClause(rows.hits.equals(3), singleTable: true).render(context);

      expect(sql, contains(r'$1'));
      expect(context.values, [3]);
    });

    test('a value-free predicate renders identically either way', () {
      final filter = rows.deletedAt.isNull();
      expect(
        render(filter),
        FilterClause(filter, singleTable: true).render(RenderContext(dialect)),
      );
    });
  });

  group('rendering the shapes a predicate uses', () {
    test('is null / is not null', () {
      expect(render(rows.deletedAt.isNull()), '"deleted_at" IS NULL');
      expect(render(rows.deletedAt.isNotNull()), '"deleted_at" IS NOT NULL');
    });

    test('and / or parenthesise consistently', () {
      expect(
        render(rows.deletedAt.isNull() & rows.hits.greaterThan(0)),
        '"deleted_at" IS NULL AND "hits" > 0',
      );
      expect(
        render(rows.deletedAt.isNull() | rows.hits.equals(0)),
        '"deleted_at" IS NULL OR "hits" = 0',
      );
    });

    test('nesting keeps its brackets', () {
      final filter =
          rows.deletedAt.isNull() & (rows.hits.equals(1) | rows.hits.equals(2));
      expect(
        render(filter),
        '"deleted_at" IS NULL AND ("hits" = 1 OR "hits" = 2)',
      );
    });

    test('not wraps', () {
      expect(
        render(not(rows.deletedAt.isNull())),
        'NOT ("deleted_at" IS NULL)',
      );
    });

    test('inList inlines every element', () {
      final sql = render(rows.name.inList(['a', "b'c"]));
      expect(sql, '"name" IN (\'a\', \'b\'\'c\')');
      expect(sql, isNot(contains('?')));
    });

    test('an empty inList stays a constant false', () {
      expect(render(rows.name.inList([])), '1 = 0');
    });

    test('like inlines its pattern', () {
      expect(render(rows.name.like('a%')), "\"name\" LIKE 'a%'");
    });

    test('rendering is byte-stable across runs', () {
      final filter = rows.deletedAt.isNull() &
          rows.name.inList(['a', 'b']) &
          rows.hits.greaterThan(2);
      expect(render(filter), render(filter));
    });

    test('singleTable false qualifies, which a predicate must not', () {
      final qualified = FilterClause(rows.deletedAt.isNull())
          .render(LiteralRenderContext(dialect));
      expect(qualified, contains('"rows".'));
      expect(render(rows.deletedAt.isNull()), isNot(contains('"rows".')));
    });
  });
}
