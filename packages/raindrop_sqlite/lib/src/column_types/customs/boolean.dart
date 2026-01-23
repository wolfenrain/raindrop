import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T boolean<T extends BooleanColumn?>(
    String name,
    Field<S, bool> field,
    // ignore: avoid_positional_boolean_parameters
    bool? value,
  ) {
    return custom<bool, int>(
      BooleanColumn.new,
      name,
      field,
      value,
      transformer: const BooleanTransfomer(),
      sqlType: 'INTEGER',
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
