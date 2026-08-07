import 'package:raindrop/dialect.dart';

/// {@template clause}
/// A self-contained, renderable fragment of a SQL statement and the unit of
/// extension for dialect authors.
///
/// A clause renders through [RenderContext] mechanics only (identifier escaping and
/// bind parameters), so the core clauses compose unchanged across dialects. To
/// emit SQL the core doesn't model like `ON CONFLICT`, `OR IGNORE`, a
/// dialect-specific `LIMIT` you implement your own [Clause] and slot it into a
/// statement with `withClause`:
///
/// ```dart
/// class _OrIgnore extends Clause {
///   const _OrIgnore();
///
///   @override
///   String render(RenderContext w) => 'OR IGNORE';
/// }
///
/// // Place it just after the INSERT verb (see the *Slot weights):
/// builder.withClause(InsertSlot.verb + 500, const _OrIgnore());
/// ```
/// {@endtemplate}
abstract class Clause {
  /// {@macro clause}
  const Clause();

  /// Renders this clause to SQL text, recording any bind values on [context].
  ///
  /// [context] is the entire context a clause is given: use
  /// [RenderContext.escapeName] for identifiers and [RenderContext.param] for values.
  ///
  /// Return an empty string to render nothing, which is how an optional clause
  /// (such as a `WHERE` with no filter) drops itself from the statement.
  String render(RenderContext context);
}

/// {@template query}
/// A statement compiled from a builder and ready to be turned into SQL: the
/// [clauses] that make it up, plus the [shape] describing how to decode the
/// rows it returns.
/// {@endtemplate}
class Query<V> {
  /// {@macro query}
  const Query({required this.clauses, required this.shape});

  /// The clauses that compose this statement.
  ///
  /// It is keyed by render weight and emitted in ascending order.
  final Map<int, Clause> clauses;

  /// The shape of how each row of this query will return.
  final Selectable<Object?> shape;
}

/// A [Clause] that renders SQL text like keywords and operators
/// (`SELECT`, `SET`, ...).
///
/// Use it directly for simple dialect verb modifiers instead of writing a
/// [Clause] subclass:
///
/// ```dart
/// builder.withClause(InsertSlot.verb + 500, const Keyword('OR IGNORE'))
/// ```
class Keyword extends Clause {
  /// Creates a literal-text clause that renders [text].
  const Keyword(this.text);

  /// The SQL text.
  final String text;

  @override
  String render(RenderContext context) => text;
}

/// Render-weight anchors for the clauses a core `INSERT` emits.
///
/// Reference these constants when positioning a dialect-specific clause with
/// `withClause` like an `OR IGNORE` modifier at `verb + 500`, or a
/// `RETURNING` clause after `body`.
///
/// The 1000-apart spacing leaves room between any two core clauses.
abstract final class InsertSlot {
  /// `INSERT` keyword.
  static const int verb = 1000;

  /// `INTO "table" (cols) VALUES (...)`.
  static const int body = 2000;
}

/// Render-weight anchors for the clauses a core `SELECT` emits.
abstract final class SelectSlot {
  /// `SELECT` keyword.
  static const int verb = 1000;

  /// The selected columns/expressions.
  static const int columns = 2000;

  /// `FROM "table"`.
  static const int from = 3000;

  /// `JOIN ...` clauses.
  static const int joins = 4000;

  /// `WHERE ...`.
  static const int where = 5000;

  /// `GROUP BY ...`.
  static const int groupBy = 6000;

  /// `HAVING ...`.
  static const int having = 6500;

  /// `ORDER BY ...`.
  static const int orderBy = 7000;

  /// `LIMIT ...`.
  static const int limit = 8000;

  /// `OFFSET ...`.
  static const int offset = 9000;
}

/// Render-weight anchors for the clauses a core `UPDATE` emits.
abstract final class UpdateSlot {
  /// `UPDATE` keyword.
  static const int verb = 1000;

  /// The target table.
  static const int table = 2000;

  /// `SET ...` assignments.
  static const int set = 3000;

  /// `WHERE ...`.
  static const int where = 4000;
}

/// Render-weight anchors for the clauses a core `DELETE` emits.
abstract final class DeleteSlot {
  /// `DELETE FROM "table"`.
  static const int from = 1000;

  /// `WHERE ...`.
  static const int where = 2000;
}
