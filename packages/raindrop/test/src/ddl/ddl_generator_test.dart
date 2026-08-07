import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';
import 'package:test/test.dart';

class _Dialect extends SqlDialect {
  const _Dialect();

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '?';

  @override
  String escapeLiteral(Object? value) => '$value';
}

/// A generator that renders nothing, to prove the base rejects that.
class _SilentGenerator extends DdlGenerator {
  _SilentGenerator(super.sendPort) : super(dialect: const _Dialect());

  @override
  String createTable(TableInfo table) => '';

  @override
  String dropTable(String tableName) => 'DROP TABLE "$tableName";';

  @override
  String alterTable(AlterTable operation) => '   ';

  @override
  String createIndex(IndexInfo index) => '';

  @override
  String dropIndex(String indexName) => '';

  @override
  String getColumnType(ColumnInfo column) => column.type;
}

void main() {
  group('DdlGenerator.generate', () {
    late ReceivePort port;
    late _SilentGenerator generator;

    setUp(() {
      port = ReceivePort();
      generator = _SilentGenerator(port.sendPort);
    });

    tearDown(() {
      generator.dispose();
      port.close();
    });

    test('an operation rendering blank SQL is an error, not a no-op', () {
      expect(
        () => generator.generate([
          const CreateTable(TableInfo(name: 't', columns: [])),
        ]),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('produced no SQL'),
          ),
        ),
      );
    });

    test('whitespace-only SQL counts as blank', () {
      expect(
        () => generator.generate([
          AlterTable(
            oldTable: const TableInfo(name: 't', columns: []),
            newTable: const TableInfo(name: 't', columns: []),
          ),
        ]),
        throwsA(isA<StateError>()),
      );
    });

    test('non-blank operations pass through joined', () {
      expect(
        generator.generate([const DropTable('a'), const DropTable('b')]),
        'DROP TABLE "a";\n\nDROP TABLE "b";',
      );
    });
  });
}
