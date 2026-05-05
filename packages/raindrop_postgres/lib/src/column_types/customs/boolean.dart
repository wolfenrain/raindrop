import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  T boolean<T extends BooleanColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return custom<BooleanColumn, bool, int, W>(
      BooleanColumn.new,
      name,
      field,
      transformer: const BooleanTransfomer(),
      sqlType: sqlType ?? 'BOOLEAN',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type BooleanColumn(Column<dynamic, bool> _)
    implements ColumnType<bool> {}

class BooleanTransfomer extends ColumnTransformer<bool, int> {
  const BooleanTransfomer();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input == 1;
}
