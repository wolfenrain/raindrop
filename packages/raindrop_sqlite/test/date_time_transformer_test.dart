import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

void main() {
  const transformer = DateTimeTransformer();

  test('encodes to epoch milliseconds', () {
    final dt = DateTime.utc(2026, 8, 1, 12);
    expect(transformer.encode(dt), dt.millisecondsSinceEpoch);
  });

  test('decodes epoch milliseconds (sqlite storage / wire int)', () {
    final dt = DateTime.utc(2026, 8, 1, 12);
    expect(transformer.decode(dt.millisecondsSinceEpoch), dt.toLocal());
  });

  test('decodes an ISO-8601 string instead of 500ing', () {
    expect(
      transformer.decode('2026-08-01T12:00:00.000Z'),
      DateTime.utc(2026, 8, 1, 12).toLocal(),
    );
  });

  test('throws a descriptive error for an unparseable string', () {
    expect(() => transformer.decode('not-a-date'), throwsFormatException);
  });
}
