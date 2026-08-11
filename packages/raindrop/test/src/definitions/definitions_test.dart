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

  group('Column', () {
    test('nullable copies the column with nullability set', () {
      final nullable = rows.age.nullable;

      expect(nullable.name, 'age');
      expect(nullable.isNullable, isTrue);
      expect(nullable.isPrimaryKey, isFalse);
      expect(nullable.sqlType, rows.age.sqlType);
      expect(nullable.table, same(rows.age.table));
    });

    test('nullable keeps primary key and auto increment marks', () {
      final nullable = rows.id.nullable;

      expect(nullable.isPrimaryKey, isTrue);
      expect(nullable.autoIncrement, isTrue);
    });

    test('toString names the value type and the column', () {
      expect(rows.age.toString(), 'Column<int>(name: age)');
    });

    test('as produces an alias carrying the original shape', () {
      final alias = ColumnOperators<int>(rows.age).as('years');

      expect(alias.alias, 'years');
      expect(alias.name, 'age');
      expect(alias.isNullable, isFalse);
    });
  });

  group('Table', () {
    test('table invokes the extra callback with the schema', () {
      _RowSchema? seen;
      final built = table(
        'extras',
        _RowSchema.new,
        dialect: dialect,
        extra: (s) => seen = s,
      );

      expect(seen, same(built));
      expect(built.$.dialect, same(dialect));
    });

    test('a projection can stand in as a derived table', () {
      final derived = db.select(rows.name).from(rows).derived(as: 'named');

      expect(derived.$.derivedFrom, isNotNull);
      expect(derived.$.name, 'named');
    });

    test('create decodes a raw column map into a row', () {
      final row = rows.$.create({
        'id': 1,
        'name': 'max',
        'age': 3,
        'active': 1,
        'score': null,
        'mood': 'grumpy',
      });

      expect(row.id, 1);
      expect(row.name, 'max');
      expect(row.age, 3);
      expect(row.active, isTrue);
      expect(row.score, isNull);
      expect(row.mood, _Mood.grumpy);
    });

    test('create throws when a null column reference is read', () {
      final broken = table('broken', _BrokenSchema.new);

      expect(
        () => broken.$.create({'value': 1}),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('null column reference'),
          ),
        ),
      );
    });

    test('values encodes a row in column order', () {
      final row = _Row(name: 'max', age: 3, active: true, mood: _Mood.happy);

      expect(rows.$.values(row), [null, 'max', 3, 1, null, 'happy']);
    });

    test('values rejects a row of another type', () {
      expect(
        () => rows.$.values('not a row'),
        throwsA(isA<StateError>()),
      );
    });

    test('addColumn rejects a column as default value', () {
      final scratch = table('scratch', _RowSchema.new);

      expect(
        () => scratch.$.addColumn<int>(
          'bad',
          (_Row r) => r.age,
          defaultValue: rows.age,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('aliased keeps the name and adds the alias', () {
      final aliased = rows.$.aliased('r');

      expect(aliased.name, 'rows');
      expect(aliased.alias, 'r');
      expect(aliased.aliasOrName, 'r');
      expect(rows.$.aliasOrName, 'rows');
    });

    test('asDerived keeps the shape over the query rows', () {
      final query =
          (db.select().from(rows) as ToQuery<dynamic, dynamic>).compile();
      final derived = rows.$.asDerived(query);

      expect(derived.name, 'rows');
      expect(derived.derivedFrom, same(query));
    });

    test('index operator finds a column by name', () {
      expect(rows.$['name'].name, 'name');
      expect(() => rows.$['missing'], throwsA(isA<StateError>()));
    });
  });

  group('Schema', () {
    test('toString is the schema type name', () {
      expect(rows.toString(), '_RowSchema');
    });

    test('as aliases the backing table', () {
      final other = rows.as('other');

      expect(other.$.alias, 'other');
      expect(other.$.name, 'rows');
    });
  });

  group('ColumnOperators', () {
    test('notEquals renders with the encoded literal', () {
      expect(render(rows.age.notEquals(3)), '"age" != 3');
      expect(render(rows.mood.notEquals(_Mood.happy)), '"mood" != \'happy\'');
    });

    test('inQuery embeds the query', () {
      final sql = render(rows.name.inQuery(db.select(rows.name).from(rows)));

      expect(sql, startsWith('"name" IN (SELECT'));
      expect(sql, endsWith(')'));
    });

    test('inList renders literals and short-circuits when empty', () {
      expect(render(rows.age.inList([1, 2])), '"age" IN (1, 2)');
      expect(render(rows.age.inList([])), '1 = 0');
    });

    test('count wraps the column', () {
      expect(render(rows.age.count().build()), 'COUNT("age")');
    });

    test('isNull and isNotNull', () {
      expect(render(rows.score.isNull()), '"score" IS NULL');
      expect(render(rows.score.isNotNull()), '"score" IS NOT NULL');
    });
  });

  group('IntOperators', () {
    test('named comparisons render their operator', () {
      expect(render(rows.age.greaterThan(1)), '"age" > 1');
      expect(render(rows.age.greaterThanOrEqual(1)), '"age" >= 1');
      expect(render(rows.age.lessThan(9)), '"age" < 9');
      expect(render(rows.age.lessThanOrEqual(9)), '"age" <= 9');
    });

    test('operator forms match the named ones', () {
      expect(render(rows.age > 1), '"age" > 1');
      expect(render(rows.age >= 1), '"age" >= 1');
      expect(render(rows.age < 9), '"age" < 9');
      expect(render(rows.age <= 9), '"age" <= 9');
    });

    test('compares against another column', () {
      expect(render(rows.age > rows.age), '"age" > "age"');
    });
  });

  group('StringOperators', () {
    test('like renders a pattern match', () {
      expect(render(rows.name.like('a%')), '"name" LIKE \'a%\'');
    });

    test('lexicographic comparisons render their operator', () {
      expect(render(rows.name.greaterThan('m')), '"name" > \'m\'');
      expect(render(rows.name.greaterThanOrEqual('m')), '"name" >= \'m\'');
      expect(render(rows.name.lessThan('m')), '"name" < \'m\'');
      expect(render(rows.name.lessThanOrEqual('m')), '"name" <= \'m\'');
    });
  });

  group('BoolOperators', () {
    test('isTrue and isFalse compare against the encoded storage value', () {
      expect(render(rows.active.isTrue()), '"active" = 1');
      expect(render(rows.active.isFalse()), '"active" = 0');
    });
  });

  group('SqlOperand', () {
    test('decode passes plain values through', () {
      expect(rows.age.decode(5), 5);
    });

    test('decode applies the transformer', () {
      expect(rows.mood.decode('happy'), _Mood.happy);
      expect(rows.active.decode(0), isFalse);
    });

    test('decode keeps null as null', () {
      expect(rows.mood.decode(null), isNull);
    });

    test('encode applies the transformer and keeps null', () {
      expect(rows.mood.encode(_Mood.grumpy), 'grumpy');
      expect(rows.mood.encode(null), isNull);
      expect(rows.age.encode(4), 4);
    });

    test('the future disguise refuses every future member', () {
      expect(rows.age.asStream, throwsUnsupportedError);
      expect(() => rows.age.catchError((_) => 0), throwsUnsupportedError);
      expect(() => rows.age.then((v) => v), throwsUnsupportedError);
      expect(
        () => rows.age.timeout(Duration.zero),
        throwsUnsupportedError,
      );
      expect(() => rows.age.whenComplete(() {}), throwsUnsupportedError);
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
  _Row({
    required this.name,
    required this.age,
    required this.active,
    this.id,
    this.score,
    this.mood,
  });

  final int? id;
  final String name;
  final int age;
  final bool active;
  final int? score;
  final _Mood? mood;
}

class _BoolTransformer extends ColumnTransformer<bool, int> {
  _BoolTransformer();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input != 0;
}

class _RowSchema extends Schema<_Row> {
  _RowSchema(super.$)
      : id = $.integer('id', (r) => r.id).primaryKey(autoIncrement: true),
        name = $.text('name', (r) => r.name),
        age = $.integer('age', (r) => r.age),
        active = $.custom(
          'active',
          (r) => r.active,
          transformer: _BoolTransformer(),
        ),
        score = $.integer('score', (r) => r.score),
        mood = $.custom('mood', (r) => r.mood, transformer: _MoodTransformer());

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<int> age;
  final ColumnType<bool> active;
  final ColumnType<int?> score;
  final ColumnType<_Mood?> mood;

  @override
  _Row fromRow(RowReader read) => _Row(
        id: read(id),
        name: read(name),
        age: read(age),
        active: read(active),
        score: read(score),
        mood: read(mood),
      );
}

/// A schema whose [fromRow] reads through a null column reference.
class _BrokenSchema extends Schema<int> {
  _BrokenSchema(super.$) : value = $.integer('value', (_) => 0);

  final ColumnType<int> value;

  @override
  int fromRow(RowReader read) => read<int>(null);
}
