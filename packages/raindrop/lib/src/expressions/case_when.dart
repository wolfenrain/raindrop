import 'package:raindrop/raindrop.dart';

/// Opens a `CASE` expression with its first `WHEN [when] THEN [then]` branch.
///
/// Chain more branches with [CaseWhen.when], every branch yields the same
/// type. A `CASE` without an `ELSE` yields `NULL` when no branch matches, so
/// the expression stays nullable until [CaseWhen.orElse] closes it:
///
/// ```dart
/// caseWhen(users.age.greaterThan(65), then: 'senior')
///     .when(users.age.greaterThan(17), then: 'adult')
///     .orElse('minor')
/// // CASE WHEN "age" > $1 THEN $2 WHEN "age" > $3 THEN $4 ELSE $5 END
/// ```
CaseWhen<V> caseWhen<V>(Filter when, {required ColumnOr<V> then}) =>
    CaseWhen<V>._([(when, then)]);

/// {@template case_when}
/// A `CASE WHEN ... THEN ...` expression, nullable for as long as no `ELSE`
/// branch has been added.
/// {@endtemplate}
class CaseWhen<V> extends Expression<V?> {
  /// {@macro case_when}
  const CaseWhen._(this._cases);

  final List<(Filter, ColumnOr<V>)> _cases;

  /// Adds a `WHEN [when] THEN [then]` branch.
  CaseWhen<V> when(Filter when, {required ColumnOr<V> then}) =>
      CaseWhen<V>._([..._cases, (when, then)]);

  /// Closes the expression with `ELSE [fallback]`, so it always yields a
  /// value.
  CaseElse<V> orElse(ColumnOr<V> fallback) => CaseElse<V>._(_cases, fallback);

  @override
  ColumnTransformer<V?, Object?>? get transformer =>
      transformerOf(_cases.first.$2);

  @override
  SQL build() => SQL([
        const RawSQL('CASE'),
        for (final (condition, result) in _cases) ...[
          const RawSQL('WHEN'),
          condition,
          const RawSQL('THEN'),
          operandFor(this, result),
        ],
        const RawSQL('END'),
      ]);
}

/// {@template case_else}
/// A `CASE` expression closed by an `ELSE`, so it always yields a value.
/// {@endtemplate}
class CaseElse<V> extends Expression<V> {
  /// {@macro case_else}
  const CaseElse._(this._cases, this._fallback);

  final List<(Filter, ColumnOr<V>)> _cases;

  final ColumnOr<V> _fallback;

  @override
  ColumnTransformer<V, Object?>? get transformer =>
      transformerOf(_cases.first.$2);

  @override
  SQL build() => SQL([
        const RawSQL('CASE'),
        for (final (condition, result) in _cases) ...[
          const RawSQL('WHEN'),
          condition,
          const RawSQL('THEN'),
          operandFor(this, result),
        ],
        const RawSQL('ELSE'),
        operandFor(this, _fallback),
        const RawSQL('END'),
      ]);
}
