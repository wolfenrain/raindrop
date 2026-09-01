import 'package:mocktail/mocktail.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

class _MockDatabase extends Mock implements CommonDatabase {}

void main() {
  group('version guard', () {
    test('accepts the minimum version and newer', () {
      expect(SQLiteDelegate.isSupportedVersion('3.44.0'), isTrue);
      expect(SQLiteDelegate.isSupportedVersion('3.44'), isTrue);
      expect(SQLiteDelegate.isSupportedVersion('3.50.4'), isTrue);
      expect(SQLiteDelegate.isSupportedVersion('4.0.0'), isTrue);
    });

    test('rejects older versions, compared numerically', () {
      expect(SQLiteDelegate.isSupportedVersion('3.43.9'), isFalse);
      expect(SQLiteDelegate.isSupportedVersion('3.9.0'), isFalse);
      expect(SQLiteDelegate.isSupportedVersion('2.0.0'), isFalse);
    });

    test('a supported library constructs a delegate', () {
      final database = sqlite3.openInMemory();
      addTearDown(database.close);

      expect(() => SQLiteDelegate(database), returnsNormally);
    });

    test('an unsupported library is refused, naming both versions', () {
      final database = _MockDatabase();
      when(() => database.select(any())).thenReturn(
        ResultSet([
          'version'
        ], [
          null
        ], [
          ['3.40.1'],
        ]),
      );

      expect(
        () => SQLiteDelegate(database),
        throwsA(
          isA<UnsupportedError>()
              .having((e) => e.message, 'message', contains('3.40.1'))
              .having((e) => e.message, 'message', contains('3.44.0')),
        ),
      );
    });
  });
}
