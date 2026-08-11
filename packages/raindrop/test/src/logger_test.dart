// ignore_for_file: cascade_invocations we want separate test invocations

import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  group('Logger', () {
    test('DeveloperLogger encodes values, falling back on toString', () {
      final logger = DeveloperLogger();
      logger.query('SELECT ?', [1, 'a']);
      logger.query('SELECT ?', [#unencodable]);
      logger.query('SELECT 1', []);
    });

    test('NoopLogger stays silent', () {
      NoopLogger().query('SELECT 1', [1]);
    });
  });
}
