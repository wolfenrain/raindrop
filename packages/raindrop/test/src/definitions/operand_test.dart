import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  group('SqlOperand is not actually a future', () {
    final expression = count();

    test('every Future member refuses', () {
      expect(expression.asStream, throwsUnsupportedError);
      expect(() => expression.then((v) => v), throwsUnsupportedError);
      expect(
        () => expression.catchError((Object _) => 0),
        throwsUnsupportedError,
      );
      expect(
        () => expression.timeout(Duration.zero),
        throwsUnsupportedError,
      );
      expect(
        () => expression.whenComplete(() {}),
        throwsUnsupportedError,
      );
    });
  });
}
