import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

/// Raw binary data, stored as a BLOB.
extension BlobColumnDefinition<R> on SchemaBuilder<R> {
  /// A [Uint8List] column, stored as-is in a BLOB.
  ColumnType<W> blob<W extends Uint8List?>(String name, Field<R, W> field) {
    return column<Uint8List, W>(name, field, sqlType: 'BLOB');
  }
}
