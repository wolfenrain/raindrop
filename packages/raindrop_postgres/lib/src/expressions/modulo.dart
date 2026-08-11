import 'package:raindrop/raindrop.dart';

/// {@template big_int_modulo}
/// Postgres `%` over a NUMERIC-backed [BigInt] column.
/// {@endtemplate}
class BigIntModulo<V extends BigInt?> extends Expression<V> {
  /// {@macro big_int_modulo}
  const BigIntModulo(this.left, this.right);

  /// The left operand.
  final Object? left;

  /// The right operand.
  final Object? right;

  @override
  SQL build() => SQL([
        const RawSQL('('),
        _operand(left),
        const RawSQL('%'),
        _operand(right),
        const RawSQL(')'),
      ]);

  static Object? _operand(Object? operand) =>
      operand is BigInt ? RawSQL('$operand') : operand;

  /// NUMERIC comes back from the driver as a string to protect precision.
  @override
  V? decode(Object? input) => switch (input) {
        null => null,
        final BigInt value => value as V,
        final String text => BigInt.parse(text) as V,
        final int value => BigInt.from(value) as V,
        _ => input as V?,
      };
}

/// Modulo on a NUMERIC-backed [BigInt] column: `t.balance % BigInt.two`.
extension BigIntModuloOperator<V extends BigInt?> on ColumnOf<V> {
  /// `this % value`
  BigIntModulo<V> operator %(ColumnOr<V> value) => BigIntModulo<V>(this, value);
}
