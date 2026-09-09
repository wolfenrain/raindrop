import 'package:raindrop/raindrop.dart';

/// `part || part || ...`.
///
/// One `NULL` part makes the whole result `NULL`, which a non-nullable
/// `String` cannot carry. Give a nullable part a fallback with [coalesce].
Concat concat(List<ColumnOr<String>> parts) => Concat(parts);

/// {@template concat}
/// The `||` operator over [parts], in order.
/// {@endtemplate}
class Concat extends Expression<String> {
  /// {@macro concat}
  Concat(this.parts) {
    if (parts.isEmpty) {
      throw ArgumentError.value(parts, 'parts', 'concat() joins at least one');
    }
  }

  /// The texts to join.
  final List<ColumnOr<String>> parts;

  @override
  SQL build() => SQL([
        const RawSQL('('),
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const RawSQL('||'),
          parts[i],
        ],
        const RawSQL(')'),
      ]);
}
