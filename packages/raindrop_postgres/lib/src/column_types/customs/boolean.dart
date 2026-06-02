import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  T boolean<T extends BooleanColumn?>(
    String name,
    Field<R, bool> field,
    // ignore: avoid_positional_boolean_parameters
  ) {
    return custom(
      BooleanColumn.new,
      name,
      field,
      transformer: const BooleanTransfomer(),
      sqlType: 'BOOLEAN',
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
