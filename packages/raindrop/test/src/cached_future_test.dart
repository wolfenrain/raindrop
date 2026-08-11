import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  group('CachedFuture', () {
    test('every Future member shares one underlying invocation', () async {
      final future = _CountingFuture();

      expect(await future, 7);
      expect(await future.then((v) => v + 1), 8);
      expect(await future.asStream().first, 7);
      expect(await future.timeout(Duration(seconds: 1)), 7);
      expect(await future.whenComplete(() {}), 7);
      expect(await future.catchError((Object _) => -1), 7);

      expect(future.calls, 1);
    });
  });
}

class _CountingFuture with CachedFuture<int> {
  int calls = 0;

  @override
  Future<int> toFuture() async {
    calls++;
    return 7;
  }
}
