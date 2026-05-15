import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  T boolean<T extends BooleanColumn?>(
    String name,
    Field<R, bool> field,
    // ignore: avoid_positional_boolean_parameters
  ) {
    return custom<bool, int>(
      BooleanColumn.new,
      name,
      field,
      transformer: const BooleanTransfomer(),
      sqlType: 'BOOLEAN',
    ) as T;
  }
}

extension type BooleanColumn(bool _) implements ColumnType<bool>, bool {
  String get name => '';
}

class BooleanTransfomer extends ColumnTransformer<bool, int> {
  const BooleanTransfomer();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input == 1;
}
