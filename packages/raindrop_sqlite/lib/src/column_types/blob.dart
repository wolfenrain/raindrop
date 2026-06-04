import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BlobColumnDefinition<R> on SchemaBuilder<R> {
  T blob<T extends BlobColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? defaultValue,
  }) {
    return column<BlobColumn, Uint8List, W>(
      BlobColumn.new,
      name,
      field,
      sqlType: 'BLOB',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension type BlobColumn(Column<dynamic, Uint8List> _)
    implements ColumnType<Uint8List> {}
