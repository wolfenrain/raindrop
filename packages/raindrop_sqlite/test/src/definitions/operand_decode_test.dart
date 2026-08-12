import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

class _Item {
  _Item({this.flag, this.amount});

  final bool? flag;
  final double? amount;
}

class _ItemSchema extends Schema<_Item> {
  _ItemSchema(super.$)
      : flag = $.boolean('flag', (s) => s.flag),
        amount = $.real('amount', (s) => s.amount);

  @override
  _Item fromRow(RowReader read) => _Item(flag: read(flag), amount: read(amount));

  final ColumnType<bool?> flag;
  final ColumnType<double?> amount;
}

void main() {
  final items = sqliteTable('items', _ItemSchema.new);

  group('SqlOperand.decode', () {
    test('still decodes a transformer-encoded value', () {
      expect(items.flag.decode(1), isTrue);
      expect(items.flag.decode(0), isFalse);
    });

    test('passes an already-native value through instead of mis-decoding it',
        () {
      // A `bool` reaching decode -- e.g. from a JSON create/update body --
      // must not be handed to BooleanTransformer.decode, which compares its
      // input to 1 and would silently turn `true` into `false`.
      expect(items.flag.decode(true), isTrue);
      expect(items.flag.decode(false), isFalse);
    });

    test('coerces a whole-number REAL value to double', () {
      // JSON has no int/double distinction, so a whole-number REAL column
      // value like 750000 arrives as int and would fail the cast to double.
      expect(items.amount.decode(750000), isA<double>());
      expect(items.amount.decode(750000), 750000.0);
    });

    test('leaves an already-double REAL value untouched', () {
      expect(items.amount.decode(750000.5), 750000.5);
    });

    test('still returns null for null', () {
      expect(items.flag.decode(null), isNull);
      expect(items.amount.decode(null), isNull);
    });
  });
}
