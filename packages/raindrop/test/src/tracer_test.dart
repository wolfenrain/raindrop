import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  group('Tracer', () {
    late Tracer tracer;

    setUp(() {
      tracer = Tracer('test');
    });

    group('synchronous functions', () {
      test('can be traced', () {
        tracer.trace('inner', (span) {
          span?.attributes['called'] = 1;
        });

        // Not `equals(0)`: a synchronous body still takes a millisecond or
        // two on a loaded machine, which is how this flaked under parallel
        // package runs.
        expect(tracer.duration!.inMilliseconds, lessThan(1000));
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
          await Future<void>.delayed(Duration(milliseconds: 100));
        });

        expect(tracer.duration!.inMilliseconds, inInclusiveRange(95, 5000));
        expect(tracer.children.length, equals(1));
        expect(tracer.children.first.attributes, equals({'called': 1}));
      });
    });

    test('dump()', () async {
      tracer.trace('inner', (span) {
        span?.attributes['called'] = 1;
      });

      final dumped = tracer.dump();

      expect(dumped['name'], 'test');
      expect(dumped['time'], matches(r'^\d+ms$'));
      final children = dumped['children']! as List<dynamic>;
      expect(children, hasLength(1));
      final child = children.single as Map<String, dynamic>;
      expect(child['name'], 'inner');
      expect(child['time'], matches(r'^\d+ms$'));
      expect(child['attributes'], {'called': 1});

      expect(
        tracer.dump(),
        equals({'name': 'test'}),
        reason: 'nothing was traced since the last dump',
      );
    });
  });
}
