import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BigIntColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> bigInt<W extends BigInt?>(String name, Field<R, W> field) {
    return custom<BigInt, Uint8List, W>(
      name,
      field,
      transformer: const BigIntTransfomer(),
      sqlType: 'BIGINT',
    );
  }
}

class BigIntTransfomer extends ColumnTransformer<BigInt, Uint8List> {
  const BigIntTransfomer();

  @override
  Uint8List encode(BigInt input) => Uint8List.fromList(
        input.toRadixString(2).split('').map(int.parse).toList(),
      );

  @override
  BigInt decode(Uint8List input) => BigInt.parse(input.join());
}
