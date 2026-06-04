import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  T boolean<T extends BooleanColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? defaultValue,
  }) {
    return custom<BooleanColumn, bool, int, W>(
      BooleanColumn.new,
      name,
      field,
      transformer: const BooleanTransformer(),
      sqlType: 'BOOLEAN',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type BooleanColumn(Column<dynamic, bool> _)
    implements ColumnType<bool> {}

class BooleanTransformer extends ColumnTransformer<bool, int> {
  const BooleanTransformer();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input == 1;
}
