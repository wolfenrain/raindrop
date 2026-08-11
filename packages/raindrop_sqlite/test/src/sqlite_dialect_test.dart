import 'dart:typed_data';

import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

void main() {
  test('names the sqlite flavor', () {
    expect(SQLiteDialect().name, 'sqlite');
  });

  group('SQLiteDialect.escapeLiteral', () {
    final dialect = SQLiteDialect();

    test('renders every literal form', () {
      expect(dialect.escapeLiteral(null), 'NULL');
      expect(dialect.escapeLiteral(true), '1');
      expect(dialect.escapeLiteral(false), '0');
      expect(dialect.escapeLiteral(42), '42');
      expect(dialect.escapeLiteral(1.5), '1.5');
      expect(dialect.escapeLiteral("it's"), "'it''s'");
      expect(
        dialect.escapeLiteral(Uint8List.fromList([0xde, 0xad])),
        "X'dead'",
      );
    });

    test('a non-finite double has no literal form', () {
      expect(
        () => dialect.escapeLiteral(double.infinity),
        throwsArgumentError,
      );
    });

    test('an unsupported type has no literal form', () {
      expect(() => dialect.escapeLiteral(#symbol), throwsArgumentError);
    });
  });
}
