import 'package:raindrop/raindrop.dart';

/// SQL `LOWER(value)`, [value] folded to lower case.
Lower lower(ColumnOr<String?> value) => Lower(value);

/// {@template lower}
/// SQL `LOWER(value)`.
/// {@endtemplate}
class Lower extends Expression<String> {
  /// {@macro lower}
  Lower(this.value);

  /// What is being folded.
  final ColumnOr<String?> value;

  @override
  SQL build() => SQL.function('LOWER', [value]);
}
