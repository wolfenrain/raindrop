import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final dialect = TestDialect();

  group('TestDialect', () {
    test('escapes names with double quotes', () {
      expect(dialect.escapeName('users'), '"users"');
    });

    test('renders one-based dollar parameters', () {
      expect(dialect.escapeParam(0), r'$1');
      expect(dialect.escapeParam(2), r'$3');
    });

    group('escapeLiteral', () {
      test('renders null', () {
        expect(dialect.escapeLiteral(null), 'NULL');
      });

      test('renders booleans as keywords', () {
        expect(dialect.escapeLiteral(true), 'TRUE');
        expect(dialect.escapeLiteral(false), 'FALSE');
      });

      test('renders numbers', () {
        expect(dialect.escapeLiteral(42), '42');
        expect(dialect.escapeLiteral(1.5), '1.5');
      });

      test('quotes strings and doubles embedded quotes', () {
        expect(dialect.escapeLiteral("it's"), "'it''s'");
      });

      test('throws for values without a portable literal form', () {
        expect(
          () => dialect.escapeLiteral(double.infinity),
          throwsArgumentError,
        );
      });
    });
  });
}
