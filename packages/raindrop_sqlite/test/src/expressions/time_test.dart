import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late Database database;
  late Raindrop db;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: _SilentLogger());
    await db.execute(
      '''
CREATE TABLE payloads (id INTEGER PRIMARY KEY AUTOINCREMENT, big BLOB NOT NULL, data BLOB NOT NULL)''',
    );
  });

  tearDown(() => database.close());

  test('unixepoch() and currentTimestamp() evaluate in the database', () async {
    final now = await db.select(unixepoch()).from(_payloads).firstOrNull;
    expect(now, isNull); // no rows yet

    await db.insert(into: _payloads).values([
      _Payload(big: BigInt.one, data: Uint8List.fromList([1])),
    ]);

    final epoch = (await db.select(unixepoch()).from(_payloads)).single;
    expect(
      epoch,
      closeTo(DateTime.now().millisecondsSinceEpoch / 1000, 60),
    );

    final stamp = (await db.select(currentTimestamp()).from(_payloads)).single;
    expect(stamp, matches(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'));
  });
}

class _Payload {
  _Payload({required this.big, required this.data, this.id});
  final int? id;
  final BigInt big;
  final Uint8List data;
}

class _PayloadSchema extends Schema<_Payload> {
  _PayloadSchema(super.$)
      : id = $.integer('id', (x) => x.id).primaryKey(autoIncrement: true),
        big = $.bigInt('big', (x) => x.big),
        data = $.blob('data', (x) => x.data);

  final ColumnType<int?> id;
  final ColumnType<BigInt> big;
  final ColumnType<Uint8List> data;

  @override
  _Payload fromRow(RowReader read) =>
      _Payload(id: read(id), big: read(big)!, data: read(data)!);
}

final _PayloadSchema _payloads = sqliteTable('payloads', _PayloadSchema.new);

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
