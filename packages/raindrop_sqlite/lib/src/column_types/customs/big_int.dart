import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BigIntColumnDefinition<R> on SchemaBuilder<R> {
  T bigInt<T extends BigIntColumn?>(
    String name,
    Field<R, BigInt> field,
  ) {
    return custom(
      BigIntColumn.new,
      name,
      field,
      transformer: const BigIntTransfomer(),
      sqlType: 'BLOB',
    ) as T;
  }
}

extension type BigIntColumn(Column<dynamic, BigInt> _)
    implements ColumnType<BigInt> {}

class BigIntTransfomer extends ColumnTransformer<BigInt, Uint8List> {
  const BigIntTransfomer();

  @override
  Uint8List encode(BigInt input) => Uint8List.fromList(
        input.toRadixString(2).split('').map(int.parse).toList(),
      );

  @override
  BigInt decode(Uint8List input) => BigInt.parse(input.join());
}
