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

  test('bigInt and blob columns round-trip through a real table', () async {
    final big = BigInt.parse('123456789012345678901234567890');
    final data = Uint8List.fromList([1, 2, 3, 255]);

    await db.insert(into: _payloads).values([
      _Payload(big: big, data: data),
    ]);
    final row = await db.select().from(_payloads).first;

    expect(row.big, big);
    expect(row.data, data);
  });

  test('bigInt round-trips zero and negatives', () async {
    final values = [
      BigInt.zero,
      BigInt.from(-1),
      BigInt.parse('-340282366920938463463374607431768211456'),
    ];
    await db.insert(into: _payloads).values([
      for (final value in values)
        _Payload(big: value, data: Uint8List.fromList([0])),
    ]);

    final stored = await db.select(_payloads.big).from(_payloads);
    expect(stored, values);
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
