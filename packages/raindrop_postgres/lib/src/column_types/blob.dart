import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

/// [Uint8List] columns that are stored as binary values.
extension BlobColumnDefinition<R> on SchemaBuilder<R> {
  /// A [Uint8List] column over `BYTEA`.
  ColumnType<W> blob<W extends Uint8List?>(String name, Field<R, W> field) {
    return column<Uint8List, W>(name, field, sqlType: 'BYTEA');
  }
}
