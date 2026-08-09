import 'package:raindrop/raindrop.dart';

/// [BigInt] columns that are stored as numeric values.
extension BigIntColumnDefinition<R> on SchemaBuilder<R> {
  /// A [BigInt] column over `NUMERIC`.
  ColumnType<W> bigInt<W extends BigInt?>(String name, Field<R, W> field) {
    return custom<BigInt, String, W>(
      name,
      field,
      transformer: const BigIntTransformer(),
      sqlType: 'NUMERIC',
    );
  }
}

/// {@template big_int_transformer}
/// Carries a [BigInt] as its decimal string, which NUMERIC accepts and
/// returns exactly.
/// {@endtemplate}
class BigIntTransformer extends ColumnTransformer<BigInt, String> {
  /// {@macro big_int_transformer}
  const BigIntTransformer();

  @override
  String encode(BigInt input) => input.toString();

  @override
  BigInt decode(String input) => BigInt.parse(input);
}
