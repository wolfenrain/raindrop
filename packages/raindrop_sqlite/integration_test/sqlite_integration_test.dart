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
    await db.execute('''
CREATE TABLE accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL UNIQUE, balance BLOB NOT NULL, active INTEGER NOT NULL, created_at INTEGER NOT NULL, rating REAL NOT NULL, avatar BLOB NOT NULL)''');
  });

  tearDown(() => database.close());

  test('insert and select round-trip every custom type', () async {
    final createdAt = DateTime.utc(2026, 8, 7, 12, 30);
    await db.insert(into: _accounts).values([
      _Account(
        email: 'a@b.c',
        balance: BigInt.parse('123456789012345678901234567890'),
        active: true,
        createdAt: createdAt,
        rating: 4.5,
        avatar: Uint8List.fromList([1, 2, 255]),
      ),
    ]);

    final row = await db.select().from(_accounts).first;
    expect(row.email, 'a@b.c');
    expect(row.balance, BigInt.parse('123456789012345678901234567890'));
    expect(row.active, isTrue);
    expect(
      row.createdAt.millisecondsSinceEpoch,
      createdAt.millisecondsSinceEpoch,
    );
    expect(row.rating, 4.5);
    expect(row.avatar, Uint8List.fromList([1, 2, 255]));
  });

  test('a negative BigInt and false bool survive the trip', () async {
    await db.insert(into: _accounts).values([
      _Account(
        email: 'neg@b.c',
        balance: BigInt.parse('-98765432109876543210'),
        active: false,
        createdAt: DateTime.utc(1970),
        rating: 0,
        avatar: Uint8List(0),
      ),
    ]);

    final row = await db.select().from(_accounts).first;
    expect(row.balance, BigInt.parse('-98765432109876543210'));
    expect(row.active, isFalse);
    expect(row.avatar, isEmpty);
  });
}

class _Account {
  _Account({
    required this.email,
    required this.balance,
    required this.active,
    required this.createdAt,
    required this.rating,
    required this.avatar,
    this.id,
  });

  final int? id;
  final String email;
  final BigInt balance;
  final bool active;
  final DateTime createdAt;
  final double rating;
  final Uint8List avatar;
}

class _AccountSchema extends Schema<_Account> {
  _AccountSchema(super.$)
      : id = $.integer('id', (a) => a.id).primaryKey(autoIncrement: true),
        email = $.text('email', (a) => a.email),
        balance = $.bigInt('balance', (a) => a.balance),
        active = $.boolean('active', (a) => a.active),
        createdAt = $.dateTime('created_at', (a) => a.createdAt),
        rating = $.real('rating', (a) => a.rating),
        avatar = $.blob('avatar', (a) => a.avatar);

  @override
  _Account fromRow(RowReader read) => _Account(
        id: read(id),
        email: read(email)!,
        balance: read(balance)!,
        active: read(active)!,
        createdAt: read(createdAt)!,
        rating: read(rating)!,
        avatar: read(avatar)!,
      );

  final ColumnType<int?> id;
  final ColumnType<String> email;
  final ColumnType<BigInt> balance;
  final ColumnType<bool> active;
  final ColumnType<DateTime> createdAt;
  final ColumnType<double> rating;
  final ColumnType<Uint8List> avatar;
}

final _AccountSchema _accounts = sqliteTable('accounts', _AccountSchema.new);

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
