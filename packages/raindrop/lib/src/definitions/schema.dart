import 'package:raindrop/raindrop.dart';

/// Reads a typed column value from a row.
///
/// Pass a column-type reference (e.g. `users.id`) and receive its decoded
/// value. Returns `null` if the underlying column was null in the row.
typedef RowReader = V Function<V extends Object?>(ColumnType<V>? column);

/// {@template schema}
/// Describes the schema (table reference) for a row of type [R].
///
/// ```dart
/// class UserSchema extends Schema<User> implements User {
///   UserSchema(super.$)
///       : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
///         name = $.text('name', (s) => s.name);
///
///   @override
///   User fromRow(RowReader read) => User(
///         id: read(id),
///         name: read(name),
///       );
///
///   @override
///   final ColumnType<int?> id;
///
///   @override
///   final ColumnType<String> name;
/// }
/// ```
/// {@endtemplate}
abstract class Schema<R> implements Selectable<R> {
  /// Every concrete schema must accept a [SchemaBuilder] for [R] and use it
  /// to register columns in its initializer list.
  Schema(SchemaBuilder<R> $) : $ = $.table;

  /// The [Table] backing this schema reference.
  final Table<Schema<R>, R> $;

  /// Construct a row instance from a typed [read] function.
  R fromRow(RowReader read);

  @override
  String toString() => '$runtimeType';
}

/// Convenience accessors on a schema reference.
extension SchemaX<S extends Schema<R>, R> on S {
  /// Create an alias of this schema reference.
  S as(String alias) => $.aliased(alias).schema as S;
}

/// {@template schema_builder}
/// Carries the [Table] reference for a schema under construction. Column
/// builder extensions (`$.integer`, `$.text`, etc.) register columns on
/// this builder's table.
/// {@endtemplate}
class SchemaBuilder<R> {
  /// Construct a builder for a specific [table].
  const SchemaBuilder(this.table);

  /// The table being built.
  final Table<Schema<R>, R> table;
}
