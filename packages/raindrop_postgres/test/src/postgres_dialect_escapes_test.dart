import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  final dialect = PostgresDialect();

  group('escapeName', () {
    test('wraps a name in double quotes', () {
      expect(dialect.escapeName('users'), '"users"');
      expect(dialect.escapeName('created_at'), '"created_at"');
    });
  });

  group('escapeParam', () {
    test('numbers parameters from one using dollar placeholders', () {
      expect(dialect.escapeParam(0), r'$1');
      expect(dialect.escapeParam(9), r'$10');
    });
  });
}
