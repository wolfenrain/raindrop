import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/src/test_dialect.dart';

/// Creates a driverless table with the given [name] and [builder].
///
/// The table is tagged with the `'test'` dialect, which is fine for tests
/// that only compile queries (goldens, `TestDelegate`-backed suites) or
/// introspect schemas. Tests running against a real database should bind
/// schemas with their driver's table function instead (`sqliteTable`,
/// `postgresTable`, ...).
///
/// Example:
/// ```dart
/// final users = testTable('users', UserSchema.new);
/// ```
S testTable<S extends Schema<R>, R>(
  String name,
  S Function(SchemaBuilder<R>) builder, [
  void Function(S table)? extra,
]) {
  return table<S, R>(name, builder, dialect: const TestDialect(), extra: extra);
}
