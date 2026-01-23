import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BlobColumnDefinition<S extends Schema<S>> on SchemaBuilder<S> {
  T blob<T extends BlobColumn?>(
    String name,
    Field<S, Uint8List> field,
    Uint8List? value,
  ) {
    return column(BlobColumn.new, name, field, value, sqlType: 'BLOB') as T;
  }
}

extension type BlobColumn(Uint8List _)
    implements ColumnType<Uint8List>, Uint8List {}
