import 'package:raindrop/raindrop.dart';

/// Creates a PostgreSQL table with the given [name] and [builder].
///
/// This function is used to define tables that are specific to PostgreSQL.
///
/// Optionally, you can provide an [indexes] callback to define indexes on the
/// table. The callback receives the schema instance and can use the [index]
/// function to define indexes.
///
/// Example:
/// ```dart
/// final users = postgresTable('users', () => User(...));
///
/// // With indexes:
/// final pets = postgresTable(
///   'pets',
///   () => Pet(
///     id: fakes.primaryKey(),
///     userId: fakes.integer(),
///     name: fakes.text(),
///   ),
///   (table) {
///     // Single column index
///     index('pets_user_id').on(table.userId);
///
///     // Unique index
///     uniqueIndex('pets_name_unique').on(table.name);
///
///     // Composite index using record syntax
///     index('pets_composite').on(table.userId, table.name);
///   },
/// );
/// ```
S postgresTable<S extends Schema<S>>(
  String name,
  S Function() builder, [
  void Function(S)? extra,
]) {
  return table(name, builder, dialect: 'postgres', extra: extra);
}
