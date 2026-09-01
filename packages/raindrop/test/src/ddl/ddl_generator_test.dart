import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';
import 'package:test/test.dart';

void main() {
  group('DdlGenerator.generate', () {
    final generator = _SilentGenerator();

    test('an operation rendering blank SQL is an error, not a no-op', () {
      expect(
        () => generator.generate([
          CreateTable(TableInfo(name: 't', columns: [])),
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
            oldTable: TableInfo(name: 't', columns: []),
            newTable: TableInfo(name: 't', columns: []),
          ),
        ]),
        throwsA(isA<StateError>()),
      );
    });

    test('non-blank operations pass through joined', () {
      expect(
        generator.generate([DropTable('a'), DropTable('b')]),
        'DROP TABLE "a";\n\nDROP TABLE "b";',
      );
    });
  });
}

class _Dialect extends SqlDialect {
  _Dialect();

  @override
  String get name => 'fake';

  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '?';

  @override
  String escapeLiteral(Object? value) => '$value';
}

/// A generator that renders nothing, to prove the base rejects that.
class _SilentGenerator extends DdlGenerator {
  _SilentGenerator() : super(dialect: _Dialect());

  @override
  String createTable(TableInfo table, {bool ifNotExists = false}) => '';

  @override
  String dropTable(String tableName) => 'DROP TABLE "$tableName";';

  @override
  String alterTable(AlterTable operation) => '   ';

  @override
  String createIndex(IndexInfo index, {bool ifNotExists = false}) => '';

  @override
  String dropIndex(String indexName) => '';

  @override
  String getColumnType(ColumnInfo column) => column.type;
}
