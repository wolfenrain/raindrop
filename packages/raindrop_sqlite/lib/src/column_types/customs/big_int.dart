import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

/// Arbitrary-precision integers, stored as a BLOB.
extension BigIntColumnDefinition<R> on SchemaBuilder<R> {
  /// A [BigInt] column: one sign byte, then the magnitude big-endian.
  ColumnType<W> bigInt<W extends BigInt?>(String name, Field<R, W> field) {
    return custom<BigInt, Uint8List, W>(
      name,
      field,
      transformer: const BigIntTransformer(),
      sqlType: 'BLOB',
    );
  }
}

/// {@template big_int_transformer}
/// Encodes a [BigInt] as one sign byte followed by big-endian magnitude
/// bytes, so values of any size round-trip exactly.
/// {@endtemplate}
class BigIntTransformer extends ColumnTransformer<BigInt, Uint8List> {
  /// {@macro big_int_transformer}
  const BigIntTransformer();

  @override
  Uint8List encode(BigInt input) {
    var magnitude = input.abs();
    final bytes = <int>[];
    while (magnitude > BigInt.zero) {
      bytes.add((magnitude & BigInt.from(0xff)).toInt());
      magnitude >>= 8;
    }
    return Uint8List.fromList([
      if (input.isNegative) 1 else 0,
      ...bytes.reversed,
    ]);
  }

  @override
  BigInt decode(Uint8List input) {
    var value = BigInt.zero;
    for (final byte in input.skip(1)) {
      value = (value << 8) | BigInt.from(byte);
    }
    return input.first == 1 ? -value : value;
  }
}
