import 'package:raindrop/raindrop.dart';

abstract class Schema<S extends Schema<S>?> implements Selectable<S> {
  const Schema();

  @override
  String toString() {
    final table = Table.getFor<S>(this as S);

    return '''
$runtimeType(${table.columns.map((c) => '${c.name}: ${c.valueOf!(this as S)}').join(', ')})''';
  }
}

extension SchemaX<S extends Schema<S>> on S {
  Table<S> get $ => Table.get(this)! as Table<S>;

  /// Returns the optional version of this schema.
  S? get optional => this;

  /// Create an alias schema with the [alias] name.
  S as(String alias) {
    final table = Table.get(this)! as Table<S>;
    return table.aliased(alias).schema;
  }
}
