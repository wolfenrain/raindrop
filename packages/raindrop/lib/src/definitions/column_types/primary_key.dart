import 'package:raindrop/raindrop.dart';

extension PrimaryKeyDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  PrimaryKey primaryKey(
    String name,
    int Function(S) schemaField, {
    int? value,
  }) {
    return column(
      PrimaryKey.new,
      schemaField,
      name: name,
      value: value ?? -1,
      isPrimaryKey: true,
    );
  }
}

extension type PrimaryKey(int _) implements IntColumn {}
