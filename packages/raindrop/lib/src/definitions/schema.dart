import 'package:raindrop/raindrop.dart';

abstract class Schema<S extends Schema<S>> implements Selectable<S> {
  const Schema();

  @override
  String toString() {
    final table = Table.getForSchema<S>();
    if (table == null) return super.toString();

    return '''
$runtimeType(${table.columns.map((column) {
      return '"${column.name}": ${column.valueOf!(this as S)}';
    }).join(', ')})''';
  }
}

extension SchemaX<S extends Schema<S>> on S {
  Table<S> get $ => Table.getForSchema<S>()!;
}
