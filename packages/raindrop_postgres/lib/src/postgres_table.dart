import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

/// Creates a PostgreSQL table with the given [name] and [builder].
///
/// Example:
/// ```dart
/// final users = postgresTable('users', UserSchema.new);
///
/// // With indexes:
/// final pets = postgresTable(
///   'pets',
///   PetSchema.new,
///   (table) {
///     index('pets_user_id').on(table.userId);
///     uniqueIndex('pets_name_unique').on(table.name);
///     index('pets_composite').on(table.userId, table.name);
///   },
/// );
/// ```
S postgresTable<S extends Schema<R>, R>(
  String name,
  S Function(SchemaBuilder<R>) builder, [
  void Function(S table)? extra,
]) {
  return table<S, R>(name, builder, dialect: dialect, extra: extra);
}
