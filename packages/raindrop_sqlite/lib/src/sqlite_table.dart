import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

/// Creates a SQLite table with the given [name] and [builder].
///
/// Example:
/// ```dart
/// final users = sqliteTable('users', UserSchema.new);
///
/// // With indexes:
/// final pets = sqliteTable(
///   'pets',
///   PetSchema.new,
///   (table) {
///     index('pets_owner').on(table.ownerId);
///     uniqueIndex('pets_name_unique').on(table.name);
///     index('pets_composite').on(table.ownerId, table.name);
///   },
/// );
/// ```
S sqliteTable<S extends Schema<R>, R>(
  String name,
  S Function(SchemaBuilder<R>) builder, [
  void Function(S table)? extra,
]) {
  return table<S, R>(name, builder, dialect: dialect, extra: extra);
}
