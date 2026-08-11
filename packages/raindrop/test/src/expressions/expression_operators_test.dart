import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final rows = testTable('rows', _RowSchema.new);
  final dialect = TestDialect();
  final db = Raindrop(TestDelegate());

  /// Renders [sql] as a single-table fragment with literals inlined.
  String render(SQL sql) => ExpressionClause(sql, singleTable: true)
      .render(LiteralRenderContext(dialect));

  group('ExpressionOperators', () {
    test('equals a literal', () {
      expect(render(sum(rows.age).equals(18)), 'SUM("age") = 18');
    });

    test('equals a column', () {
      expect(render(sum(rows.age).equals(rows.age)), 'SUM("age") = "age"');
    });

    test('equals encodes the literal through the transformer', () {
      expect(
        render(max(rows.mood).equals(_Mood.grumpy)),
        'MAX("mood") = \'grumpy\'',
      );
    });

    test('notEquals a literal', () {
      expect(render(sum(rows.age).notEquals(0)), 'SUM("age") != 0');
    });

    test('isNull and isNotNull', () {
      expect(render(max(rows.score).isNull()), 'MAX("score") IS NULL');
      expect(render(max(rows.score).isNotNull()), 'MAX("score") IS NOT NULL');
    });

    test('inList renders each literal', () {
      expect(
        render(lower(rows.name).inList(['a', 'b'])),
        'LOWER("name") IN (\'a\', \'b\')',
      );
    });

    test('inList on an empty list can never match', () {
      expect(render(lower(rows.name).inList([])), '1 = 0');
    });

    test('inQuery embeds the query', () {
      final sql = render(
        lower(rows.name).inQuery(db.select(rows.name).from(rows)),
      );

      expect(sql, startsWith('LOWER("name") IN (SELECT'));
      expect(sql, endsWith(')'));
    });
  });

  group('NumericExpressionOperators', () {
    test('greaterThan and greaterThanOrEqual', () {
      expect(render(sum(rows.age).greaterThan(18)), 'SUM("age") > 18');
      expect(
        render(sum(rows.age).greaterThanOrEqual(18)),
        'SUM("age") >= 18',
      );
    });

    test('lessThan and lessThanOrEqual', () {
      expect(render(sum(rows.age).lessThan(18)), 'SUM("age") < 18');
      expect(render(sum(rows.age).lessThanOrEqual(18)), 'SUM("age") <= 18');
    });
  });

  group('StringExpressionOperators', () {
    test('like matches a pattern', () {
      expect(render(lower(rows.name).like('a%')), 'LOWER("name") LIKE \'a%\'');
    });

    test('greaterThan and greaterThanOrEqual order lexicographically', () {
      expect(render(trim(rows.name).greaterThan('m')), 'TRIM("name") > \'m\'');
      expect(
        render(trim(rows.name).greaterThanOrEqual('m')),
        'TRIM("name") >= \'m\'',
      );
    });

    test('lessThan and lessThanOrEqual order lexicographically', () {
      expect(render(trim(rows.name).lessThan('m')), 'TRIM("name") < \'m\'');
      expect(
        render(trim(rows.name).lessThanOrEqual('m')),
        'TRIM("name") <= \'m\'',
      );
    });
  });
}

enum _Mood { happy, grumpy }

class _MoodTransformer extends ColumnTransformer<_Mood, String> {
  _MoodTransformer();

  @override
  String encode(_Mood input) => input.name;

  @override
  _Mood decode(String input) => _Mood.values.byName(input);
}

class _Row {
  _Row({required this.name, required this.age, this.id, this.score, this.mood});

  final int? id;
  final String name;
  final int age;
  final int? score;
  final _Mood? mood;
}

class _RowSchema extends Schema<_Row> {
  _RowSchema(super.$)
      : id = $.integer('id', (r) => r.id).primaryKey(autoIncrement: true),
        name = $.text('name', (r) => r.name),
        age = $.integer('age', (r) => r.age),
        score = $.integer('score', (r) => r.score),
        mood = $.custom('mood', (r) => r.mood, transformer: _MoodTransformer());

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<int> age;
  final ColumnType<int?> score;
  final ColumnType<_Mood?> mood;

  @override
  _Row fromRow(RowReader read) => _Row(
        id: read(id),
        name: read(name),
        age: read(age),
        score: read(score),
        mood: read(mood),
      );
}
