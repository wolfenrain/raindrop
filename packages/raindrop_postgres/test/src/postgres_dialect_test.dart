import 'dart:typed_data';

import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  final dialect = PostgresDialect();

  group('splitStatements', () {
    test('a dollar-quoted function body is not split on its semicolons', () {
      final statements = dialect.splitStatements(r'''
CREATE FUNCTION bump() RETURNS trigger AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
SELECT 1;''');

      expect(statements, hasLength(2));
      expect(statements.first, contains('RETURN NEW;'));
      expect(statements.last, 'SELECT 1');
    });

    test('a tagged dollar quote may contain an untagged one', () {
      final statements = dialect.splitStatements(
        r"SELECT $fn$ nested $$ ; $$ still quoted $fn$; SELECT 'x;y';",
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

  group('escapeLiteral', () {
    test('renders every literal form', () {
      expect(dialect.escapeLiteral(null), 'NULL');
      expect(dialect.escapeLiteral(true), 'TRUE');
      expect(dialect.escapeLiteral(false), 'FALSE');
      expect(dialect.escapeLiteral(42), '42');
      expect(dialect.escapeLiteral(1.5), '1.5');
      expect(dialect.escapeLiteral("it's"), "'it''s'");
      expect(
        dialect.escapeLiteral(Uint8List.fromList([0xde, 0xad])),
        r"'\xdead'::bytea",
      );
    });

    test('non-finite doubles and unknown types have no literal form', () {
      expect(() => dialect.escapeLiteral(double.nan), throwsArgumentError);
      expect(() => dialect.escapeLiteral(#symbol), throwsArgumentError);
    });
  });
}
