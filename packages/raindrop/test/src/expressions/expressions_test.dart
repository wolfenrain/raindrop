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

  /// Renders the [expression] the same way.
  String renderExpression(Expression<dynamic> expression) =>
      render(expression.build());

  group('Arithmetic', () {
    test('column plus literal renders parenthesized addition', () {
      expect(renderExpression(rows.age + 1), '("age" + 1)');
    });

    test('column minus literal renders subtraction', () {
      expect(renderExpression(rows.age - 2), '("age" - 2)');
    });

    test('column times column renders multiplication', () {
      expect(renderExpression(rows.age * rows.age), '("age" * "age")');
    });

    test('column divided by literal renders division', () {
      expect(renderExpression(rows.age / 2), '("age" / 2)');
    });

    test('integer column modulo literal renders remainder', () {
      expect(renderExpression(rows.age % 7), '("age" % 7)');
    });

    test('accepts an expression as an operand', () {
      final expression = Arithmetic<int>(
        abs(rows.age),
        ArithmeticOperator.add,
        5,
      );

      expect(renderExpression(expression), '(ABS("age") + 5)');
    });

    test('every operator carries its SQL symbol', () {
      expect(ArithmeticOperator.add.sql, '+');
      expect(ArithmeticOperator.subtract.sql, '-');
      expect(ArithmeticOperator.multiply.sql, '*');
      expect(ArithmeticOperator.divide.sql, '/');
      expect(ArithmeticOperator.modulo.sql, '%');
    });
  });

  group('functions', () {
    test('abs renders ABS around its operand', () {
      expect(renderExpression(abs(rows.age)), 'ABS("age")');
    });

    test('avg renders AVG around its operand', () {
      expect(renderExpression(avg(rows.age)), 'AVG("age")');
    });

    test('avg decodes every storage type drivers produce', () {
      final average = avg(rows.age);

      expect(average.decode(null), isNull);
      expect(average.decode(30.25), 30.25);
      expect(average.decode(30), 30.0);
      expect(average.decode('30.25'), 30.25);
    });

    test('sum renders SUM around its operand', () {
      expect(renderExpression(sum(rows.age)), 'SUM("age")');
    });

    test('sum decodes every storage type drivers produce', () {
      final total = sum(rows.age);

      expect(total.decode(null), isNull);
      expect(total.decode(6), 6);
      expect(total.decode(6.0), 6);
      expect(total.decode('123'), 123);

      final fractional = Sum<double?>(1.5);
      expect(fractional.decode('1.5'), 1.5);
      expect(fractional.decode(3), 3.0);
    });

    test('lower renders LOWER around its operand', () {
      expect(renderExpression(lower(rows.name)), 'LOWER("name")');
    });

    test('upper renders UPPER around its operand', () {
      expect(renderExpression(upper(rows.name)), 'UPPER("name")');
    });

    test('trim renders TRIM around its operand', () {
      expect(renderExpression(trim(rows.name)), 'TRIM("name")');
    });
  });

  group('min and max', () {
    test('render MIN and MAX around their operands', () {
      expect(renderExpression(min(rows.age)), 'MIN("age")');
      expect(renderExpression(max(rows.age)), 'MAX("age")');
    });

    test('take their transformer from the wrapped column', () {
      expect(min(rows.mood).transformer, isNotNull);
      expect(max(rows.mood).transformer, isNotNull);
    });

    test('have no transformer over a plain column', () {
      expect(min(rows.age).transformer, isNull);
      expect(max(rows.age).transformer, isNull);
    });
  });

  group('CaseWhen', () {
    test('a single branch stays open, without an ELSE', () {
      expect(
        renderExpression(caseWhen(rows.age.greaterThan(65), then: 'senior')),
        '''CASE WHEN "age" > 65 THEN 'senior' END''',
      );
    });

    test('chains branches in order and orElse closes the expression', () {
      expect(
        renderExpression(
          caseWhen(rows.age.greaterThan(65), then: 'senior')
              .when(rows.age.greaterThan(17), then: 'adult')
              .orElse('minor'),
        ),
        '''CASE WHEN "age" > 65 THEN 'senior' WHEN "age" > 17 THEN 'adult' ELSE 'minor' END''',
      );
    });

    test('accepts compound conditions and operand results', () {
      expect(
        renderExpression(
          caseWhen(
            rows.age.greaterThan(10) & rows.name.notEquals('x'),
            then: rows.name,
          ).orElse(upper(rows.name)),
        ),
        '''CASE WHEN "age" > 10 AND "name" != 'x' THEN "name" ELSE UPPER("name") END''',
      );
    });

    test('takes its transformer from the first branch', () {
      final open = caseWhen(rows.age.greaterThan(1), then: rows.mood);
      expect(open.transformer, isNotNull);
      expect(open.orElse(rows.mood).transformer, isNotNull);
      expect(caseWhen(rows.age.greaterThan(1), then: 1).transformer, isNull);
    });

    test('encodes a literal branch value through that transformer', () {
      expect(
        renderExpression(
          caseWhen(rows.age.greaterThan(1), then: rows.mood)
              .orElse(_Mood.happy),
        ),
        '''CASE WHEN "age" > 1 THEN "mood" ELSE 'happy' END''',
      );
    });
  });

  group('count', () {
    test('renders COUNT(*) without an operand', () {
      expect(renderExpression(count()), 'COUNT(*)');
    });

    test('renders COUNT over a column operand', () {
      expect(renderExpression(count(rows.name)), 'COUNT("name")');
    });

    test('is available directly on a column', () {
      expect(renderExpression(rows.age.count()), 'COUNT("age")');
    });
  });

  group('coalesce', () {
    test('renders COALESCE with the encoded fallback', () {
      expect(renderExpression(coalesce(rows.score, 7)), 'COALESCE("score", 7)');
    });

    test('encodes the fallback through the column transformer', () {
      expect(
        renderExpression(coalesce(rows.mood, _Mood.happy)),
        "COALESCE(\"mood\", 'happy')",
      );
    });

    test('takes its transformer from the wrapped column', () {
      expect(coalesce(rows.mood, _Mood.happy).transformer, isNotNull);
      expect(coalesce(rows.score, 7).transformer, isNull);
    });
  });

  group('distinct', () {
    test('renders DISTINCT before its operand', () {
      expect(renderExpression(distinct(rows.name)), 'DISTINCT "name"');
    });

    test('composes with an aggregate', () {
      expect(
        renderExpression(count(distinct(rows.name))),
        'COUNT(DISTINCT "name")',
      );
    });

    test('takes its transformer from the wrapped operand', () {
      expect(distinct(rows.mood).transformer, isNotNull);
    });

    test('has no transformer over a non-operand selectable', () {
      expect(Distinct<_Row>(rows.$).transformer, isNull);
    });
  });

  group('AliasedExpression', () {
    test('as names an expression without changing its SQL', () {
      final aliased = max(rows.age).as('oldest');

      expect(aliased.alias, 'oldest');
      expect(renderExpression(aliased), 'MAX("age")');
    });

    test('keeps the transformer of the expression it names', () {
      expect(max(rows.mood).as('m').transformer, isNotNull);
      expect(max(rows.age).as('m').transformer, isNull);
    });
  });

  group('subquery', () {
    test('renders as a parenthesized SELECT', () {
      final youngest = subquery(db.select(min(rows.age)).from(rows));

      final sql = renderExpression(youngest);
      expect(sql, startsWith('(SELECT'));
      expect(sql, endsWith(')'));
      expect(sql, contains('MIN'));
      expect(sql, contains('FROM'));
    });

    test('takes its transformer from the selected operand', () {
      final moody = subquery(db.select(max(rows.mood)).from(rows));

      expect(moody.transformer, isNotNull);
    });

    test('has no transformer when selecting whole rows', () {
      final whole = subquery(db.select().from(rows));

      expect(whole.transformer, isNull);
    });
  });

  group('raw', () {
    test('renders the fragment verbatim', () {
      expect(renderExpression(raw<int>('1 + 1')), '1 + 1');
    });

    test('parts mixes column handles with SQL text', () {
      expect(renderExpression(raw.parts([rows.age, '> 0'])), '"age" > 0');
    });

    test('parts binds a wrapped value instead of inlining it', () {
      final context = RenderContext(dialect);
      final fragment = raw.parts([rows.name, '=', bind('max')]);

      final sql =
          ExpressionClause(fragment.build(), singleTable: true).render(context);

      expect(sql, r'"name" = $1');
      expect(context.values, ['max']);
    });

    test('bound values keep what they wrap', () {
      expect(bind(42).value, 42);
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
