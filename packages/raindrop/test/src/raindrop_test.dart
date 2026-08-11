import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  group('Raindrop', () {
    test('execute reaches the delegate', () async {
      final delegate = TestDelegate();
      final db = Raindrop(delegate);

      await db.execute('SELECT 1');

      expect(delegate.statements.map((s) => s.sql), ['SELECT 1']);
    });

    test('execute records its query on the active trace span', () async {
      final delegate = TestDelegate();
      final db = Raindrop(delegate);

      Raindrop.tracer.isTracing = true;
      addTearDown(() => Raindrop.tracer.isTracing = false);

      await db.execute('SELECT 2', [1]);

      expect(delegate.statements.map((s) => s.sql), ['SELECT 2']);
    });
  });
}
