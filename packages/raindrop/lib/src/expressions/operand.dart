import 'dart:async';

import 'package:raindrop/raindrop.dart';

/// The transformer of [operand], or null when it has none.
///
/// The whole point of the operand union: this does not care whether it was
/// handed a column or an expression, so an expression can take its transformer
/// from whatever it wraps and nesting propagates without either level knowing
/// what the other is.
ColumnTransformer<V, Object?>? transformerOf<V>(ColumnOr<V> operand) =>
    operand is SqlOperand<V> ? operand.transformer : null;

/// Prepares [value] to sit opposite [subject] in a predicate.
///
/// A column or an expression is already SQL and passes through untouched. Only
/// a literal is encoded, using [subject]'s transformer, the comparison is
/// against how that operand is stored, not how it looks in Dart.
Object? operandFor<V>(SqlOperand<V> subject, ColumnOr<V> value) =>
    switch (value) {
      final SqlOperand<dynamic> operand => operand,
      _ => subject.encode(value as V),
    };

/// Lets a type be passed where a plain value is expected.
///
/// `ColumnOr<V>` is `FutureOr<V>`, which admits `V` or `Future<V>`. Anything
/// that poses as `Future<V>` therefore slips into the second arm, that is how
/// a `Column` can be handed to `equals()` alongside a literal.
///
/// A deliberate fiction: `FutureOr` is the only implicit union Dart has, so
/// faking a `Future` is the only way to widen a parameter without forcing the
/// caller to wrap every value. Every `Future` member here throws, because none
/// of them is ever reached.
///
/// Used by both `Column` and `Expression`. Because there is exactly one
/// `FutureOr`, both land in the same union: a slot that accepts one accepts the
/// other, and anywhere that distinction matters has to check at runtime.
///
/// It also carries [transformer] and the [encode]/[decode] pair, so a caller
/// holding an operand can convert its values without knowing which kind it is.
mixin SqlOperand<V> implements Future<V> {
  static Never _notAFuture() => throw UnsupportedError(
        '''
This is not a real Future, it only poses as one so it can be used where a value is expected.''',
      );

  /// How this operand's values convert to and from their stored form.
  ///
  /// `null` when the operand is already its own storage type, which is the
  /// common case and the default.
  ColumnTransformer<V, Object?>? get transformer => null;

  /// This operand's value in its stored form.
  Object? encode(V? input) {
    if (input == null) return null;

    return switch (transformer) {
      final ColumnTransformer<dynamic, dynamic> transformer =>
        transformer.encode(input),
      _ => input
    };
  }

  /// A stored value back in this operand's own type.
  V? decode(Object? input) {
    if (input == null) return null;

    // `input` may already be in the app-native shape [V] instead of the
    // storage-encoded shape a transformer expects — e.g. a JSON create/update
    // body handing a boolean column a native `bool` rather than the `int`
    // SQLite stores it as. In that case there is nothing to decode, and
    // handing it to the transformer would silently turn `true` into `false`.
    if (input is V) return input as V;

    final decoded = switch (transformer) {
      final ColumnTransformer<dynamic, dynamic> transformer =>
        transformer.decode(input),
      _ => input
    };

    // JSON has no int/double distinction, so a whole-number REAL column value
    // like `750000` arrives as `int`, not `double`. `<double>[] is List<V>` is
    // true for both `V == double` and `V == double?` (List is covariant).
    if (decoded is int && <double>[] is List<V>) {
      return decoded.toDouble() as V;
    }

    return decoded as V?;
  }

  @override
  Stream<V> asStream() => _notAFuture();

  @override
  Future<V> catchError(Function onError, {bool Function(Object error)? test}) =>
      _notAFuture();

  @override
  Future<R> then<R>(
    FutureOr<R> Function(V value) onValue, {
    Function? onError,
  }) =>
      _notAFuture();

  @override
  Future<V> timeout(Duration timeLimit, {FutureOr<V> Function()? onTimeout}) =>
      _notAFuture();

  @override
  Future<V> whenComplete(FutureOr<void> Function() action) => _notAFuture();
}
