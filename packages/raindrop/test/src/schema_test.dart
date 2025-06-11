// ignore_for_file: prefer_const_constructors

import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

class TestSchema extends Schema<TestSchema> {
  TestSchema({
    required String key,
  }) : key = _builder.text('key', (s) => s.key, value: key);

  final TextColumn key;

  static const _builder = SchemaBuilder<TestSchema>();
}

void main() {
  Raindrop.tracer.isTracing = true;

  group('$Schema', () {
    test('toString()', () {
      expect(
        TestSchema(key: 'test').toString(),
        equals('$TestSchema {"key":"test"}'),
      );
    });
  });
}
