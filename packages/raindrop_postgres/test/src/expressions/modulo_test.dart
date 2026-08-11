import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  final db = Raindrop(_RenderDelegate());

  group('BigIntModulo', () {
    test('inlines a BigInt operand as its decimal form', () {
      expect(
        db.select(_accounts.balance % BigInt.two).from(_accounts).toString(),
        'SELECT ("balance" % 2) FROM "accounts"',
      );
    });

    test('decodes every storage form the driver produces', () {
      final remainder = _accounts.balance % BigInt.two;

      expect(remainder.decode(null), isNull);
      expect(remainder.decode('123456789012345678901234567890'),
          BigInt.parse('123456789012345678901234567890'));
      expect(remainder.decode(BigInt.one), BigInt.one);
      expect(remainder.decode(7), BigInt.from(7));
    });
  });
}

class _Account {
  _Account({required this.balance, this.id});

  final int? id;
  final BigInt balance;
}

class _AccountSchema extends Schema<_Account> {
  _AccountSchema(super.$)
      : id = $.integer('id', (a) => a.id).primaryKey(autoIncrement: true),
        balance = $.bigInt('balance', (a) => a.balance);

  final ColumnType<int?> id;
  final ColumnType<BigInt> balance;

  @override
  _Account fromRow(RowReader read) =>
      _Account(id: read(id), balance: read(balance)!);
}

final _AccountSchema _accounts = postgresTable('accounts', _AccountSchema.new);

/// Renders queries through the Postgres dialect without ever executing them.
class _RenderDelegate extends RaindropDelegate {
  _RenderDelegate() : super(dialect: PostgresDialect());

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) {
    throw UnsupportedError('render-only delegate');
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) {
    throw UnsupportedError('render-only delegate');
  }
}
