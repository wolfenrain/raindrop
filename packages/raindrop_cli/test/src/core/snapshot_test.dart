import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop/snapshot.dart';
import 'package:raindrop_cli/raindrop_cli.dart';
import 'package:test/test.dart';

void main() {
  group('MigrationSnapshot', () {
    final schema = SchemaSnapshot(
      dialect: 'sqlite',
      tables: {
        'users': TableSnapshot(
          name: 'users',
          columns: {
            'id': ColumnSnapshot(
              name: 'id',
              type: 'INTEGER',
              isNullable: false,
              primaryKey: true,
              autoIncrement: true,
            ),
          },
        ),
      },
    );
    final snapshot = MigrationSnapshot(
      version: MigrationSnapshot.currentVersion,
      id: MigrationSnapshot.generateId(),
      prevId: MigrationSnapshot.nullUuid,
      schema: schema,
    );

    test('round-trips through JSON', () {
      final restored = MigrationSnapshot.fromJson(snapshot.toJson());
      expect(restored.toJson(), snapshot.toJson());
      expect(restored.id, snapshot.id);
      expect(restored.schema.tables['users']!.columns['id']!.primaryKey, true);
    });

    test('nests the schema under its own key', () {
      final document = jsonDecode(snapshot.toJson()) as Map<String, dynamic>;
      expect(document.keys, containsAll(['version', 'id', 'prevId', 'schema']));
      expect(
        (document['schema'] as Map<String, dynamic>).keys,
        containsAll(['dialect', 'tables', 'indexes']),
      );
    });

    test('exposes the schema dialect', () {
      expect(snapshot.dialect, 'sqlite');
    });

    test('of() stamps the current version', () {
      final wrapped = MigrationSnapshot.of(
        schema,
        id: 'a',
        prevId: MigrationSnapshot.nullUuid,
      );
      expect(wrapped.version, MigrationSnapshot.currentVersion);
      expect(wrapped.schema, same(schema));
    });

    test('generateId is a v4 uuid, and unique', () {
      final id = MigrationSnapshot.generateId();
      expect(
        id,
        matches(
          RegExp(
            '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
            r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(MigrationSnapshot.generateId(), isNot(id));
    });

    test('copyWith replaces only the identity', () {
      final copy = snapshot.copyWith(id: 'a', prevId: 'b');
      expect(copy.id, 'a');
      expect(copy.prevId, 'b');
      expect(copy.schema, same(snapshot.schema));
    });

    test('copyWith without arguments keeps the identity', () {
      expect(snapshot.copyWith().id, snapshot.id);
      expect(snapshot.copyWith().prevId, snapshot.prevId);
    });

    test('save and load round-trip through disk, load returns null when absent',
        () async {
      final dir = Directory.systemTemp.createTempSync('raindrop_snapshot');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'meta', '0000_snapshot.json');

      expect(await MigrationSnapshot.load(path), isNull);
      await snapshot.save(path);
      final loaded = await MigrationSnapshot.load(path);
      expect(loaded!.toJson(), snapshot.toJson());
    });

    group('strict parsing', () {
      Map<String, dynamic> document() =>
          jsonDecode(snapshot.toJson()) as Map<String, dynamic>;

      Matcher failsWith(String fragment) => throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains(fragment),
            ),
          );

      void expectRejected(Map<String, dynamic> data, String fragment) {
        expect(
          () => MigrationSnapshot.fromJson(jsonEncode(data)),
          failsWith(fragment),
        );
      }

      test('rejects an unknown top-level key', () {
        expectRejected(document()..['dialect'] = 'sqlite', '"dialect"');
      });

      test('rejects a missing top-level key', () {
        expectRejected(document()..remove('prevId'), '"prevId"');
      });

      test('rejects an unsupported version', () {
        expectRejected(document()..['version'] = '2', 'version "2"');
      });

      test('rejects a schema the library refuses', () {
        final data = document();
        (data['schema'] as Map<String, dynamic>)['renamed'] = true;
        expectRejected(data, '"renamed"');
      });
    });
  });
}
