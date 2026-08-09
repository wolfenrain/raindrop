import 'package:raindrop/raindrop.dart';

extension BooleanColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> boolean<W extends bool?>(String name, Field<R, W> field) {
    return custom<bool, int, W>(
      name,
      field,
      transformer: const BooleanTransformer(),
      sqlType: 'INTEGER',
    );
  }
}

class BooleanTransformer extends ColumnTransformer<bool, int> {
  const BooleanTransformer();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input == 1;
}
