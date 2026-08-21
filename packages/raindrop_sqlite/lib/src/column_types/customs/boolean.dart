import 'package:raindrop/raindrop.dart';

/// Booleans, stored as an INTEGER.
extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  /// A [bool] column: `true` is stored as `1` and `false` as `0`.
  ColumnType<W> boolean<W extends bool?>(
    String name,
    Field<R, W> field, {
    ColumnOr<bool>? defaultValue,
  }) {
    return custom<bool, int, W>(
      name,
      field,
      transformer: const BooleanTransformer(),
      sqlType: 'INTEGER',
      defaultValue: defaultValue,
    );
  }
}

/// {@template boolean_transformer}
/// Encodes a [bool] as an [int], where `true` becomes `1` and `false`
/// becomes `0`.
/// {@endtemplate}
class BooleanTransformer extends ColumnTransformer<bool, int> {
  /// {@macro boolean_transformer}
  const BooleanTransformer();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input == 1;
}
