import 'package:raindrop/raindrop.dart';

/// SQL `(a || b || ...)`, the [parts] joined into one string.
///
/// Rendered with the `||` operator, which every dialect parses.
Concat concat(List<ColumnOr<String?>> parts) => Concat(parts);

/// {@template concat}
/// SQL `(a || b || ...)`.
/// {@endtemplate}
class Concat extends Expression<String> {
  /// {@macro concat}
  Concat(this.parts) {
    if (parts.isEmpty) {
      throw ArgumentError.value(parts, 'parts', 'concat() joins at least one');
    }
  }

  /// What is being joined, in order.
  final List<ColumnOr<String?>> parts;

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
