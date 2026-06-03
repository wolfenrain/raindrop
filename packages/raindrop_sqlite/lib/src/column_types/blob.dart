import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BlobColumnDefinition<R> on SchemaBuilder<R> {
  T blob<T extends BlobColumn?>(
    String name,
    Field<R, Uint8List> field,
  ) {
    return column(BlobColumn.new, name, field, sqlType: 'BLOB') as T;
  }
}

extension type BlobColumn(Column<dynamic, Uint8List> _)
    implements ColumnType<Uint8List> {}
