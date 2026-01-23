import 'dart:async';

import 'package:raindrop/raindrop.dart';

/// Creating an index on one or more columns.
///
/// ```dart
/// final pets = sqliteTable(
///   'pets',
///   () => Pet(
///     id: fakes.primaryKey(),
///     userId: fakes.integer(),
///     name: fakes.text(),
///   ),
///   (table) {
///     // Single column index
///     index('pets_owner').on(table.ownerId);
///
///     // Composite index using record syntax
///     index('pets_composite').on(table.userId, table.name);
///   },
/// );
/// ```
IndexBuilder index(String name) => IndexBuilder(name, isUnique: false);

/// Creating a unique index on one or more columns.
///
/// ```dart
/// final pets = sqliteTable(
///   'pets',
///   () => Pet(
///     id: fakes.primaryKey(),
///     userId: fakes.integer(),
///     name: fakes.text(),
///   ),
///   (table) {
///     // Unique index
///     uniqueIndex('pets_name_unique').on(table.name);
///   },
/// );
/// ```
IndexBuilder uniqueIndex(String name) => IndexBuilder(name, isUnique: true);

/// Represents a database index definition.
class Index {
  /// Creates an [Index] with the given properties.
  Index(
    this.name,
    this.columns, {
    this.isUnique = false,
  }) {
    if (Zone.current[#extra] case final Table table) {
      table.addIndex(this);
    }
  }

  /// The name of the index.
  final String name;

  /// The columns that make up the index.
  final List<Column<dynamic, dynamic>> columns;

  /// Whether this index enforces uniqueness.
  final bool isUnique;
}

/// Builder for creating index definitions with fluent API.
///
/// Use the [index] function to create instances of this builder.
class IndexBuilder {
  /// Creates an [IndexBuilder] with the given index name.
  IndexBuilder(this.name, {required this.isUnique});

  /// The name of the index being built.
  final String name;

  /// If the index is unique or not.
  final bool isUnique;
}
