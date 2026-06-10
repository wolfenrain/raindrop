import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

extension BlobColumnDefinition<R> on SchemaBuilder<R> {
  ColumnType<W> blob<W extends Uint8List?>(String name, Field<R, W> field) {
    return column<Uint8List, W>(name, field, sqlType: 'BLOB');
  }
}
