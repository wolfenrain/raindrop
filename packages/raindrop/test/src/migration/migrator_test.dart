import 'dart:async';

import 'package:raindrop/dialect.dart';
import 'package:test/test.dart';

class _FakeDialect extends SqlDialect {
  @override
  String escapeName(String name) => '"$name"';

  @override
  String escapeParam(int number) => '?$number';
}

class _FakeTransactionDelegate extends TransactionDelegate {
  _FakeTransactionDelegate(super.dialect);

  final executedQueries = <(String, List<Object?>)>[];

  @override
  Future<DatabaseResult> execute(
    String query,
    List<Object?> values,
  ) async {
    executedQueries.add((query, values));
    return const DatabaseResult(
      columns: [],
      rows: [],
      rowsAffected: 0,
      lastInsertedRowId: null,
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    return transaction(this);
  }

  @override
  Future<void> rollback() async {}
}

class _FakeRaindropDelegate extends RaindropDelegate {
  _FakeRaindropDelegate({required this.appliedMigrations})
      : txDelegate = _FakeTransactionDelegate(_FakeDialect()),
        super(dialect: _FakeDialect());

  final List<(String, String)> appliedMigrations;
  final _FakeTransactionDelegate txDelegate;
  final executedQueries = <(String, List<Object?>)>[];
  int transactionCount = 0;

  @override
  Future<void> onOpen() async {}

  @override
  Future<void> onClose() async {}

  @override
  Future<DatabaseResult> execute(
    String query,
    List<Object?> values,
  ) async {
    executedQueries.add((query, values));
    if (query.contains('SELECT')) {
      return DatabaseResult(
        columns: ['tag', 'checksum'],
        rows: [
          for (final (tag, checksum) in appliedMigrations) [tag, checksum],
        ],
        rowsAffected: 0,
        lastInsertedRowId: null,
      );
    }
    return const DatabaseResult(
      columns: [],
      rows: [],
      rowsAffected: 0,
      lastInsertedRowId: null,
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    transactionCount++;
    return runZoned(
      () => transaction(txDelegate),
      zoneValues: {#delegate: txDelegate},
    );
  }
}

void main() {
  group('migrate', () {
    test(
      'creates tracking table and does nothing with no migrations',
      () async {
        final delegate = _FakeRaindropDelegate(appliedMigrations: []);
        final db = Raindrop(delegate);

        await migrate(db, []);

        expect(
          delegate.executedQueries.any(
            (q) => q.$1.contains('CREATE TABLE IF NOT EXISTS'),
          ),
          isTrue,
        );
        expect(delegate.transactionCount, equals(0));
      },
    );

    test('executes pending migrations in transactions', () async {
      final delegate = _FakeRaindropDelegate(appliedMigrations: []);
      final db = Raindrop(delegate);

      await migrate(
        db,
        [
          const Migration(
            '0000_initial',
            'CREATE TABLE "users" (id INTEGER)',
          ),
        ],
      );

      expect(delegate.transactionCount, equals(1));

      // Check that the SQL statement was executed in the transaction.
      expect(
        delegate.txDelegate.executedQueries.any(
          (q) => q.$1.contains('CREATE TABLE "users"'),
        ),
        isTrue,
      );

      // Check that the migration was recorded.
      expect(
        delegate.txDelegate.executedQueries.any(
          (q) => q.$1.contains('INSERT INTO "_raindrop_migrations"'),
        ),
        isTrue,
      );
    });

    test('skips already-applied migrations', () async {
      // Use the correct checksum for the SQL content.
      final delegate = _FakeRaindropDelegate(
        appliedMigrations: [('0000_initial', 'e26f7dbb5b5b246f')],
      );
      final db = Raindrop(delegate);

      await migrate(
        db,
        [
          const Migration(
            '0000_initial',
            'CREATE TABLE "users" (id INTEGER)',
          ),
        ],
      );

      expect(delegate.transactionCount, equals(0));
    });

    test('throws MigrationChecksumMismatch on modified migration', () async {
      final delegate = _FakeRaindropDelegate(
        appliedMigrations: [('0000_initial', 'wrong_checksum_xx')],
      );
      final db = Raindrop(delegate);

      await expectLater(
        () => migrate(
          db,
          [
            const Migration(
              '0000_initial',
              'CREATE TABLE "users" (id INTEGER)',
            ),
          ],
        ),
        throwsA(isA<MigrationChecksumMismatch>()),
      );
    });

    test(
      'executes only new migrations when some are already applied',
      () async {
        final delegate = _FakeRaindropDelegate(
          appliedMigrations: [('0000_initial', 'e26f7dbb5b5b246f')],
        );
        final db = Raindrop(delegate);

        await migrate(
          db,
          [
            const Migration(
              '0000_initial',
              'CREATE TABLE "users" (id INTEGER)',
            ),
            const Migration(
              '0001_add_name',
              'ALTER TABLE "users" ADD COLUMN "name" TEXT',
            ),
          ],
        );

        // Only one transaction for the new migration.
        expect(delegate.transactionCount, equals(1));

        expect(
          delegate.txDelegate.executedQueries.any(
            (q) => q.$1.contains('ALTER TABLE'),
          ),
          isTrue,
        );
      },
    );

    test(
      'splits multi-statement SQL and executes each separately',
      () async {
        final delegate = _FakeRaindropDelegate(appliedMigrations: []);
        final db = Raindrop(delegate);

        await migrate(
          db,
          [
            const Migration(
              '0000_initial',
              'CREATE TABLE "a" (id INTEGER);\n'
                  'CREATE TABLE "b" (id INTEGER)',
            ),
          ],
        );

        // Two SQL statements + one INSERT for recording = 3 calls.
        expect(delegate.txDelegate.executedQueries, hasLength(3));
      },
    );
  });

  group('MigrationChecksumMismatch', () {
    test('toString provides useful information', () {
      const error = MigrationChecksumMismatch(
        '0000_test',
        'abc123',
        'def456',
      );
      expect(error.toString(), contains('0000_test'));
      expect(error.toString(), contains('abc123'));
      expect(error.toString(), contains('def456'));
    });
  });
}
