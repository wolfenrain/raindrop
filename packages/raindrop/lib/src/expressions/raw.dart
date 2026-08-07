import 'package:raindrop/raindrop.dart';

/// The escape hatch: a fragment of SQL used verbatim, wherever the DSL has no
/// spelling for it.
///
/// Usable in both positions, since which one it is only the caller knows:
///
/// ```dart
/// // As a predicate: where, having, checks.
/// check('one_ref', raw('("a" IS NOT NULL) + ("b" IS NOT NULL) = 1')).on(t);
///
/// // As a value, typed by the caller.
/// db.select(raw<String>("glob('c*', name)")).from(users);
/// ```
///
/// To mix column handles and bound values into a fragment, use [RawParts.parts]
Raw<V> raw<V extends Object?>(String sql) => Raw<V>(sql);

/// The signature of [raw].
typedef RawFunction = Raw<V> Function<V extends Object?>(String sql);

/// `raw.parts`, the composite form of [raw].
extension RawParts on RawFunction {
  /// A fragment assembled from [parts]: a `String` is SQL, a column
  /// or expression renders as itself (qualified and escaped in context), and
  /// anything else becomes a bound parameter. A *string* meant as a value
  /// must be wrapped in [bind], since a bare string always means SQL.
  ///
  /// ```dart
  /// db.select().from(users).where(raw.parts([users.age, '> 0']));
  /// // WHERE "age" > 0
  ///
  /// db.select().from(users).where(
  ///       raw.parts([users.name, '=', bind(input)]),
  ///     );
  /// // WHERE "name" = $1
  /// ```
  Raw<V> parts<V extends Object?>(List<Object?> parts) => Raw<V>.parts(parts);
}

/// Marks [value] as a bound parameter inside [RawParts.parts].
Bound bind(Object? value) => Bound(value);

/// {@template bound}
/// A value that must travel as a bind parameter.
/// {@endtemplate}
class Bound {
  /// {@macro bound}
  const Bound(this.value);

  /// The value to bind.
  final Object? value;
}

/// {@template raw}
/// A verbatim fragment of SQL.
/// {@endtemplate}
class Raw<V extends Object?> extends Expression<V> implements Filter {
  /// {@macro raw}
  Raw(String sql) : chunks = [RawSQL(sql)];

  /// {@macro raw}
  ///
  /// See [RawParts.parts] for what each part means.
  Raw.parts(List<Object?> parts)
      : chunks = [
          for (final part in parts)
            switch (part) {
              final String sql => RawSQL(sql),
              final Bound bound => bound.value,
              _ => part,
            },
        ];

  /// The fragment's pieces, in [SQL] chunk form.
  final List<Object?> chunks;

  @override
  SQL build() => SQL(chunks);

  @override
  Filter operator &(Filter? right) =>
      right != null ? LogicalFilter(this, right) : this;

  @override
  Filter operator |(Filter? right) =>
      right != null ? LogicalFilter(this, right, or: true) : this;
}
