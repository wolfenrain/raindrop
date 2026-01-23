import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BigIntColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T bigInt<T extends BigIntColumn?>(
    String name,
    Field<S, BigInt> field,
    BigInt? value,
  ) {
    return custom<BigInt, Uint8List>(
      BigIntColumn.new,
      name,
      field,
      value,
      transformer: const BigIntTransfomer(),
      sqlType: 'BLOB',
    ) as T;
  }
}

extension type BigIntColumn(BigInt _) implements ColumnType<BigInt>, BigInt {}

class BigIntTransfomer extends ColumnTransformer<BigInt, Uint8List> {
  const BigIntTransfomer();

  @override
  Uint8List encode(BigInt input) => Uint8List.fromList(
        input.toRadixString(2).split('').map(int.parse).toList(),
      );

  @override
  BigInt decode(Uint8List input) => BigInt.parse(input.join());
}
