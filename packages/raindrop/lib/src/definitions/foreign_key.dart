import 'package:raindrop/raindrop.dart';

/// Referential action to take when the referenced row is deleted or updated.
enum ReferentialAction {
  /// Delete or update the row from the parent table and automatically delete
  /// or update the matching rows in the child table.
  cascade,

  /// Set the foreign key column(s) in the child table to NULL.
  setNull,

  /// Set the foreign key column(s) in the child table to their default values.
  setDefault,

  /// Reject the delete or update operation for the parent table.
  restrict,

  /// Similar to RESTRICT but deferred until the end of the transaction.
  noAction,
}

/// {@template foreign_key_reference}
/// Represents a foreign key reference from a column to another table's column.
/// {@endtemplate}
class ForeignKeyReference {
  /// {@macro foreign_key_reference}
  const ForeignKeyReference({
    required this.referencedColumnGetter,
    this.onDelete,
    this.onUpdate,
  });

  /// A function that returns the referenced column.
  ///
  /// Using a getter allows lazy resolution, which is necessary when tables
  /// reference each other.
  final Column Function() referencedColumnGetter;

  /// The action to take when the referenced row is deleted.
  final ReferentialAction? onDelete;

  /// The action to take when the referenced row is updated.
  final ReferentialAction? onUpdate;

  /// The referenced column.
  Column get referencedColumn => referencedColumnGetter();

  /// The name of the referenced table.
  String get referencedTable => referencedColumn.table.name;

  /// The name of the referenced column.
  String get referencedColumnName => referencedColumn.name;
}
