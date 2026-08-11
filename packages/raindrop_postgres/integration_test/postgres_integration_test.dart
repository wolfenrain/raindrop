import 'dart:typed_data';

import 'package:postgres/postgres.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  Connection? connection;
  late Raindrop db;

  setUpAll(() async {
    try {
      connection = await Connection.open(
        Endpoint(
          host: 'localhost',
          port: 15432,
          database: 'postgres',
          username: 'postgres',
          password: 'test',
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 3),
        ),
      );
      // ignore: avoid_catches_without_on_clauses anything thrown must skip
    } catch (_) {
      connection = null;
    }
  });

  tearDownAll(() => connection?.close());

  setUp(() async {
    final open = connection;
    if (open == null) return;
    db = Raindrop(PostgresDelegate(open), logger: _SilentLogger());
    await db.execute('DROP TABLE IF EXISTS accounts');
    await db.execute(
      '''
CREATE TABLE accounts (id SERIAL PRIMARY KEY, email TEXT NOT NULL UNIQUE, balance NUMERIC NOT NULL, active BOOLEAN NOT NULL, created_at TIMESTAMP NOT NULL, rating DOUBLE PRECISION NOT NULL, avatar BYTEA NOT NULL)''',
    );
  });

  test('insert and select round-trip every custom type', () async {
    if (connection == null) return markTestSkipped('no Postgres');
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
        row.createdAt.millisecondsSinceEpoch, createdAt.millisecondsSinceEpoch);
    expect(row.rating, 4.5);
    expect(row.avatar, Uint8List.fromList([1, 2, 255]));
  });

  test('bigInt modulo runs over NUMERIC', () async {
    if (connection == null) return markTestSkipped('no Postgres');
    final balance = BigInt.parse('123456789012345678901234567890');
    await db.insert(into: _accounts).values([
      _Account(
        email: 'mod@b.c',
        balance: balance,
        active: true,
        createdAt: DateTime.utc(2026),
        rating: 1,
        avatar: Uint8List(1),
      ),
    ]);

    final remainders =
        await db.select(_accounts.balance % BigInt.from(7)).from(_accounts);

    expect(remainders.single, balance % BigInt.from(7));
  });

  test('a transaction commits, a failing one rolls back', () async {
    if (connection == null) return markTestSkipped('no Postgres');
    await db.transaction((tx) async {
      await tx.execute(
        'INSERT INTO accounts '
        '(email, balance, active, created_at, rating, avatar) '
        r"VALUES ('t@x.y', 0, true, now(), 0, '\x00')",
        [],
      );
    });
    await expectLater(
      db.transaction((tx) async {
        await tx.execute(
          'INSERT INTO accounts '
          '(email, balance, active, created_at, rating, avatar) '
          r"VALUES ('gone@x.y', 0, true, now(), 0, '\x00')",
          [],
        );
        throw StateError('abort');
      }),
      throwsStateError,
    );

    final emails = await db.select(_accounts.email).from(_accounts);
    expect(emails, ['t@x.y']);
  });

  test('a nested transaction is a savepoint', () async {
    if (connection == null) return markTestSkipped('no Postgres');
    await db.transaction((tx) async {
      await tx.execute(
        'INSERT INTO accounts '
        '(email, balance, active, created_at, rating, avatar) '
        r"VALUES ('outer@x.y', 0, true, now(), 0, '\x00')",
        [],
      );
      await expectLater(
        tx.transaction((inner) async {
          await inner.execute(
            'INSERT INTO accounts '
            '(email, balance, active, created_at, rating, avatar) '
            r"VALUES ('inner@x.y', 0, true, now(), 0, '\x00')",
            [],
          );
          throw StateError('abort inner');
        }),
        throwsStateError,
      );
    });

    final emails = await db.select(_accounts.email).from(_accounts);
    expect(emails, ['outer@x.y']);
  });

  test('delegate.rollback() aborts via TransactionRollback', () async {
    if (connection == null) return markTestSkipped('no Postgres');
    await expectLater(
      db.transaction((tx) async {
        await tx.execute(
          'INSERT INTO accounts '
          '(email, balance, active, created_at, rating, avatar) '
          r"VALUES ('gone@x.y', 0, true, now(), 0, '\x00')",
          [],
        );
        await tx.delegate.rollback();
      }),
      throwsA(isA<TransactionRollback>()),
    );

    expect(await db.select(_accounts.email).from(_accounts), isEmpty);
  });

  group('onConflict', () {
    _Account account(String email) => _Account(
          email: email,
          balance: BigInt.zero,
          active: true,
          createdAt: DateTime.now(),
          rating: 0,
          avatar: Uint8List.fromList([0]),
        );

    test('DoNothing skips the conflicting row', () async {
      if (connection == null) return markTestSkipped('no Postgres');
      await db.insert(into: _accounts).values([account('dup@x.y')]);
      await db.insert(into: _accounts).values([account('dup@x.y')]).onConflict(
        [_accounts.$['email']],
        const DoNothing(),
      );

      expect(await db.select(_accounts.email).from(_accounts), ['dup@x.y']);
    });

    test('DoUpdate updates the existing row', () async {
      if (connection == null) return markTestSkipped('no Postgres');
      await db.insert(into: _accounts).values([account('dup@x.y')]);
      await db.insert(into: _accounts).values([account('dup@x.y')]).onConflict(
        [_accounts.$['email']],
        DoUpdate([_accounts.active.to(false)]),
      );

      final row = await db.select().from(_accounts).single;
      expect(row.active, isFalse);
    });
  });

  test('now() and genRandomUuid() evaluate in the database', () async {
    if (connection == null) return markTestSkipped('no Postgres');
    await db.insert(into: _accounts).values([
      _Account(
        email: 'fn@x.y',
        balance: BigInt.zero,
        active: true,
        createdAt: DateTime.now(),
        rating: 0,
        avatar: Uint8List.fromList([0]),
      ),
    ]);

    final stamp = (await db.select(now()).from(_accounts)).single;
    expect(
      stamp.difference(DateTime.now()).inMinutes.abs(),
      lessThan(5),
    );

    final uuid = (await db.select(genRandomUuid()).from(_accounts)).single;
    expect(uuid, matches(r'^[0-9a-f-]{36}$'));
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

  final ColumnType<int?> id;

  final ColumnType<String> email;

  final ColumnType<BigInt> balance;

  final ColumnType<bool> active;

  final ColumnType<DateTime> createdAt;

  final ColumnType<double> rating;

  final ColumnType<Uint8List> avatar;

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
}

final _AccountSchema _accounts = postgresTable('accounts', _AccountSchema.new);

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}
