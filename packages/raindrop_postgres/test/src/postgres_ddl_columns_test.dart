import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop_postgres/ddl.dart' as entry_point;
import 'package:test/test.dart';

void main() {
  group('main', () {
    test('wires a generator to the send port', () async {
      final port = ReceivePort();
      entry_point.main([], port.sendPort);

      expect(await port.first, isA<SendPort>());
      port.close();
    });
  });

  group('alterTable', () {
    final generator = entry_point.PostgresDdlGenerator();

    test('dropped and added columns become DROP and ADD COLUMN', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('id', type: 'INTEGER'), _column('nickname')],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('id', type: 'INTEGER'), _column('surname')],
          ),
        ),
      );

      expect(sql, '''
ALTER TABLE "users" DROP COLUMN "nickname";
ALTER TABLE "users" ADD COLUMN "surname" TEXT NOT NULL;''');
    });
  });
}

ColumnInfo _column(String name, {String type = 'TEXT'}) {
  return ColumnInfo(name: name, type: type, isNullable: false);
}
