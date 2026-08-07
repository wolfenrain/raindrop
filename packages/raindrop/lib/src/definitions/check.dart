import 'package:raindrop/raindrop.dart';

/// A table-level CHECK constraint.
///
/// ```dart
/// final pets = table('pets', PetSchema.new, (table) {
///   check('pets_legs', table.legs.greaterThan(0)).on(table);
/// });
/// ```
///
/// For what the DSL cannot say, the predicate can be a `raw()` fragment:
///
/// ```dart
/// check('one_ref', raw('("a" IS NOT NULL) + ("b" IS NOT NULL) = 1')).on(t);
/// ```
CheckBuilder check(String name, Filter predicate) =>
    CheckBuilder(name, predicate);

/// Represents a table-level CHECK constraint definition.
class Check {
  /// Creates a check constraint.
  const Check(this.name, this.predicate);

  /// The constraint name.
  final String name;

  /// The predicate rows must satisfy.
  final Filter predicate;
}

/// Builder for creating check definitions with fluent API.
///
/// Use [check] to create instances of this builder.
class CheckBuilder {
  /// Creates a builder for a constraint.
  const CheckBuilder(this.name, this.predicate);

  /// The constraint name.
  final String name;

  /// The predicate rows must satisfy.
  final Filter predicate;

  /// Attach the constraint to [schema]'s table.
  Check on(Schema<dynamic> schema) {
    final constraint = Check(name, predicate);
    Table.get(schema)!.addCheck(constraint);
    return constraint;
  }
}
