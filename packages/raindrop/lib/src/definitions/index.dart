import 'package:raindrop/raindrop.dart';

/// Creating an index on one or more columns.
///
/// ```dart
/// final pets = sqliteTable(
///   'pets',
///   PetSchema.new,
///   (table) {
///     // Single column index
///     index('pets_owner').on(table.ownerId);
///
///     // Composite index using record syntax
///     index('pets_composite').on(table.userId, table.name);
///   },
/// );
/// ```
///
/// Pass [where] to create a partial index, using the same [Filter] syntax as a
/// query `where` (`index('idx', where: t.deletedAt.isNull())`). The
/// predicate must be param-free because partial-index predicates cannot bind
/// values.
IndexBuilder index(String name, {Filter? where}) =>
    IndexBuilder(name, isUnique: false, where: where);

/// Creating a unique index on one or more columns.
///
/// ```dart
/// final pets = sqliteTable(
///   'pets',
///   PetSchema.new,
///   (table) {
///     // Unique index
///     uniqueIndex('pets_name_unique').on(table.name);
///   },
/// );
/// ```
///
/// Pass [where] to create a partial unique index. See [index].
IndexBuilder uniqueIndex(String name, {Filter? where}) =>
    IndexBuilder(name, isUnique: true, where: where);

/// Represents a database index definition.
class Index {
  /// Creates an [Index] with the given properties.
  const Index(this.name, this.columns, {this.isUnique = false, this.where});

  /// The name of the index.
  final String name;

  /// The columns that make up the index.
  final List<Column<dynamic, dynamic>> columns;

  /// Whether this index enforces uniqueness.
  final bool isUnique;

  /// Optional partial-index predicate. When set, the generated index is
  /// restricted to rows matching `WHERE <where>`.
  final Filter? where;
}

/// Builder for creating index definitions with fluent API.
///
/// Use the [index] function to create instances of this builder.
class IndexBuilder {
  /// Creates an [IndexBuilder] with the given index name.
  IndexBuilder(this.name, {required this.isUnique, this.where});

  /// The name of the index being built.
  final String name;

  /// If the index is unique or not.
  final bool isUnique;

  /// Optional partial-index predicate. See [index].
  final Filter? where;
}
