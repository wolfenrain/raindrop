import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  group('Tracer failures', () {
    late Tracer tracer;

    setUp(() {
      tracer = Tracer('test');
    });

    test('a synchronous throw fails the span and rethrows', () {
      expect(
        () => tracer.trace('boom', (span) => throw StateError('boom')),
        throwsStateError,
      );

      expect(tracer.children, isNotEmpty);
      for (final child in tracer.children) {
        expect(child.name, 'boom');
        expect(child.hasEnded, isTrue);
        expect(child.duration, isNotNull);
      }
    });

    test('an asynchronous failure fails the span and rethrows', () async {
      await expectLater(
        tracer.trace('boom', (span) async {
          await Future<void>.delayed(Duration(milliseconds: 1));
          throw StateError('boom');
        }),
        throwsStateError,
      );

      await Future<void>.delayed(Duration.zero);

      expect(tracer.children, hasLength(1));
      expect(tracer.children.single.name, 'boom');
      expect(tracer.children.single.hasEnded, isTrue);
    });
  });
}
