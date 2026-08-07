import 'package:raindrop/raindrop.dart';

/// SQL `UPPER(value)`, [value] folded to upper case.
Upper upper(ColumnOr<String?> value) => Upper(value);

/// {@template upper}
/// SQL `UPPER(value)`.
/// {@endtemplate}
class Upper extends Expression<String> {
  /// {@macro upper}
  Upper(this.value);

  /// What is being folded.
  final ColumnOr<String?> value;

  @override
  SQL build() => SQL.function('UPPER', [value]);
}
