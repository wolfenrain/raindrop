// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs
import 'package:raindrop/raindrop.dart';

extension IndexBuilderOn on IndexBuilder {
  /// Create an index on the given column(s).
  ///
  /// ```dart
  /// index('composite_idx').on(schema.col1, schema.col2);
  /// uniqueIndex('unique_idx').on(schema.col1);
  /// ```
  Index on(ColumnType<dynamic>? c0,
      [ColumnType<dynamic>? c1,
      ColumnType<dynamic>? c2,
      ColumnType<dynamic>? c3,
      ColumnType<dynamic>? c4,
      ColumnType<dynamic>? c5,
      ColumnType<dynamic>? c6,
      ColumnType<dynamic>? c7,
      ColumnType<dynamic>? c8,
      ColumnType<dynamic>? c9,
      ColumnType<dynamic>? c10,
      ColumnType<dynamic>? c11,
      ColumnType<dynamic>? c12,
      ColumnType<dynamic>? c13,
      ColumnType<dynamic>? c14,
      ColumnType<dynamic>? c15,
      ColumnType<dynamic>? c16,
      ColumnType<dynamic>? c17,
      ColumnType<dynamic>? c18,
      ColumnType<dynamic>? c19]) {
    final cols = [
      c0,
      c1,
      c2,
      c3,
      c4,
      c5,
      c6,
      c7,
      c8,
      c9,
      c10,
      c11,
      c12,
      c13,
      c14,
      c15,
      c16,
      c17,
      c18,
      c19
    ];
    final resolved = [...cols.whereType<Column<dynamic, dynamic>>()];

    final index = Index(name, resolved, isUnique: isUnique, where: where);
    resolved.first.table.addIndex(index);
    return index;
  }
}
