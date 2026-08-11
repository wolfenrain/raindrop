import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';
import 'package:test/test.dart';

void main() {
  group('serveDdlGenerator', () {
    late ReceivePort port;
    late ReceivePort commandPort;
    late _Generator generator;
    late SendPort commands;

    setUp(() async {
      port = ReceivePort();
      generator = _Generator();
      commandPort = serveDdlGenerator(generator, port.sendPort);
      commands = await port.first as SendPort;
    });

    tearDown(() {
      commandPort.close();
      port.close();
    });

    Future<Map<String, dynamic>> send(Map<String, dynamic> message) async {
      final replyPort = ReceivePort();
      commands.send({...message, 'replyPort': replyPort.sendPort});
      final reply = await replyPort.first;
      replyPort.close();
      return (reply! as Map).cast();
    }

    test('generates SQL for operations sent over the port', () async {
      final reply = await send({
        'action': 'generate',
        'operations': [DropTable('a').toMap(), DropTable('b').toMap()],
      });
      expect(reply, {
        'success': true,
        'sql': 'DROP TABLE "a";\n\nDROP TABLE "b";',
      });
    });

    test('a message without an action defaults to generate', () async {
      final reply = await send({
        'operations': [DropTable('a').toMap()],
      });
      expect(reply['success'], isTrue);
      expect(reply['sql'], 'DROP TABLE "a";');
    });

    test('an unknown action reports failure instead of throwing', () async {
      final reply = await send({'action': 'explode'});
      expect(reply['success'], isFalse);
      expect(reply['error'], 'Unknown action: explode');
    });

    test('a failing generate replies with the error and its trace', () async {
      final reply = await send({
        'action': 'generate',
        'operations': [
          {'type': 'nonsense'},
        ],
      });
      expect(reply['success'], isFalse);
      expect(reply['error'], contains('Unknown operation type: nonsense'));
      // The stack trace travels with the message.
      expect(reply['error'], contains('#0'));
    });

    test('a message that is not a map is ignored, later ones still work',
        () async {
      commands.send('not a map');
      final reply = await send({
        'operations': [DropTable('a').toMap()],
      });
      expect(reply['success'], isTrue);
    });

    test('render covers every operation kind', () {
      final index = IndexInfo(name: 'i', tableName: 't', columns: ['a']);
      expect(
        generator.render(CreateTable(TableInfo(name: 't', columns: []))),
        'CREATE TABLE "t";',
      );
      expect(generator.render(DropTable('t')), 'DROP TABLE "t";');
      expect(
        generator.render(
          AlterTable(
            oldTable: TableInfo(name: 't', columns: []),
            newTable: TableInfo(name: 't', columns: []),
          ),
        ),
        'ALTER TABLE "t";',
      );
      expect(generator.render(CreateIndex(index: index)), 'CREATE INDEX "i";');
      expect(
        generator.render(DropIndex('i', tableName: 't')),
        'DROP INDEX "i";',
      );
    });

    test('escapeName delegates to the dialect', () {
      expect(generator.escapeName('table'), '"table"');
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

/// A generator whose per-operation renderings are trivially recognizable.
class _Generator extends DdlGenerator {
  _Generator() : super(dialect: _Dialect());

  @override
  String createTable(TableInfo table) =>
      'CREATE TABLE ${escapeName(table.name)};';

  @override
  String dropTable(String tableName) => 'DROP TABLE ${escapeName(tableName)};';

  @override
  String alterTable(AlterTable operation) =>
      'ALTER TABLE ${escapeName(operation.tableName)};';

  @override
  String createIndex(IndexInfo index) =>
      'CREATE INDEX ${escapeName(index.name)};';

  @override
  String dropIndex(String indexName) => 'DROP INDEX ${escapeName(indexName)};';

  @override
  String getColumnType(ColumnInfo column) => column.type;
}
