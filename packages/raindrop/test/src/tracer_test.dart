import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  group('$Tracer', () {
    late Tracer tracer;

    setUp(() {
      tracer = Tracer('test');
    });

    group('synchronous functions', () {
      test('can be traced', () {
        tracer.trace('inner', (span) {
          span?.attributes['called'] = 1;
        });

        expect(tracer.duration?.inMilliseconds, equals(0));
        expect(tracer.children.length, equals(1));
        expect(tracer.children.first.isTracing, isTrue);
        expect(tracer.children.first.isNotTracing, isFalse);
        expect(tracer.children.first.attributes, equals({'called': 1}));
        expect(tracer.hasEnded, isTrue);
      });
    });

    group('asynchronous functions', () {
      test('can be traced', () async {
        await tracer.trace('inner', (span) async {
          span?.attributes['called'] = 1;
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });

        expect(tracer.duration?.inMilliseconds, closeTo(100, 5));
        expect(tracer.children.length, equals(1));
        expect(tracer.children.first.attributes, equals({'called': 1}));
      });
    });

    test('dump()', () async {
      tracer.trace('inner', (span) {
        span?.attributes['called'] = 1;
      });

      expect(
        tracer.dump(),
        equals({
          'name': 'test',
          'time': '0ms',
          'children': [
            {'name': 'inner', 'time': '0ms', 'attributes': <String, dynamic>{}},
          ],
        }),
      );

      // Nothing was traced since the last dump.
      expect(tracer.dump(), equals({'name': 'test'}));
    });
  });
}
