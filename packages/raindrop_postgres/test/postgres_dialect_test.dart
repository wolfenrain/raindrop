import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  const dialect = PostgresDialect();

  group('splitStatements', () {
    test('a dollar-quoted function body is not split on its semicolons', () {
      final statements = dialect.splitStatements('''
CREATE FUNCTION bump() RETURNS trigger AS \$\$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;
SELECT 1;''');

      expect(statements, hasLength(2));
      expect(statements.first, contains('RETURN NEW;'));
      expect(statements.last, 'SELECT 1');
    });

    test('a tagged dollar quote may contain an untagged one', () {
      final statements = dialect.splitStatements(
        "SELECT \$fn\$ nested \$\$ ; \$\$ still quoted \$fn\$; SELECT 'x;y';",
      );

      expect(statements, hasLength(2));
      expect(statements.first, contains('still quoted'));
    });

    test('plain statements split as everywhere else', () {
      expect(
        dialect.splitStatements("SELECT 'a;b'; SELECT 2;"),
        ["SELECT 'a;b'", 'SELECT 2'],
      );
    });
  });
}
