import 'package:raindrop/dialect.dart';
import 'package:test/test.dart';

void main() {
  group('translate', () {
    final query = Query<Object?>(
      clauses: {
        1: Keyword('SELECT'),
        2: ExpressionClause(SQL([1])),
      },
      shape: SelectableResult<Object?>([]),
    );

    test('renders the query clauses and gathers the bind values', () {
      final (sql, values) = _Dialect().translate(query);
      expect(sql, r'SELECT $1');
      expect(values, [1]);
    });

    test('records the SQL and values on the span when tracing', () {
      Raindrop.tracer.isTracing = true;
      addTearDown(() {
        Raindrop.tracer
          ..isTracing = false
          ..dump();
      });

      final (sql, values) = _Dialect().translate(query);
      expect(sql, r'SELECT $1');
      expect(values, [1]);

      final span = Raindrop.tracer.children.last;
      expect(span.name, '_Dialect.translate');
      expect(span.attributes, {
        'sql': r'SELECT $1',
        'values': [1],
      });
    });
  });

  group('splitStatements with a dialect quote delimiter', () {
    final dialect = _DollarDialect();

    test('a semicolon inside the delimiter does not split', () {
      expect(
        dialect.splitStatements(r'SELECT $$a;b$$; SELECT 1'),
        [r'SELECT $$a;b$$', 'SELECT 1'],
      );
    });

    test('the contents are not interpreted', () {
      expect(
        dialect.splitStatements(r"SELECT $$it's -- not a comment$$"),
        [r"SELECT $$it's -- not a comment$$"],
      );
    });

    test('an unterminated delimiter consumes the rest of the script', () {
      expect(
        dialect.splitStatements(r'SELECT $$a;b'),
        [r'SELECT $$a;b'],
      );
    });

    test('the base dialect never matches a delimiter', () {
      expect(
        _Dialect().splitStatements(r'SELECT $$a;b$$'),
        [r'SELECT $$a', r'b$$'],
      );
    });
  });
}

class _Dialect extends SqlDialect {
  _Dialect();

  @override
  String get name => 'fake';

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '\$${number + 1}';

  @override
  String escapeLiteral(Object? value) => '$value';
}

/// A dialect with a Postgres-style dollar-quoted string form, to exercise
/// how [SqlDialect.splitStatements] consumes a matched quote delimiter.
class _DollarDialect extends _Dialect {
  _DollarDialect();

  @override
  int matchQuoteDelimiter(String sql, int index) =>
      sql.startsWith(r'$$', index) ? 2 : 0;
}
