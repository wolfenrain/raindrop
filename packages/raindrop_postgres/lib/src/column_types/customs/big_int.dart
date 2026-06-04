import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BigIntColumnDefinition<R> on SchemaBuilder<R> {
  T bigInt<T extends BigIntColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? defaultValue,
  }) {
    return custom<BigIntColumn, BigInt, Uint8List, W>(
      BigIntColumn.new,
      name,
      field,
      transformer: const BigIntTransformer(),
      sqlType: 'BIGINT',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type BigIntColumn(Column<dynamic, BigInt> _)
    implements ColumnType<BigInt> {}

class BigIntTransformer extends ColumnTransformer<BigInt, Uint8List> {
  const BigIntTransformer();

  @override
  Uint8List encode(BigInt input) => Uint8List.fromList(
        input.toRadixString(2).split('').map(int.parse).toList(),
      );

  @override
  BigInt decode(Uint8List input) => BigInt.parse(input.join());
}
