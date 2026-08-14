import 'package:raindrop/dialect.dart';

/// What a Postgres `INSERT` does when it hits a conflict.
///
/// See [OnConflictClause] and the `onConflict` builder extension.
sealed class ConflictAction {
  const ConflictAction();
}

/// `DO NOTHING`, skip the conflicting row.
class DoNothing extends ConflictAction {
  /// Creates a `DO NOTHING` action.
  const DoNothing();
}

/// `DO UPDATE SET ...`, update the existing row with [assignments].
///
/// ```dart
/// DoUpdate([users.name.to('updated'), users.seen.to(true)])
/// ```
class DoUpdate extends ConflictAction {
  /// Creates a `DO UPDATE SET ...` action from column [assignments].
  const DoUpdate(this.assignments);

  /// The `column.to(value)` assignments to apply to the existing row.
  final List<Updateable<dynamic>> assignments;
}

/// An `ON CONFLICT [(target)] DO ...` clause for a Postgres insert.
///
/// Renders itself like any other [Clause]. `PostgresInsert` simply
/// includes it in its [Query.clauses].
class OnConflictClause extends Clause {
  /// Creates a conflict clause for the given [target] columns and [action].
  const OnConflictClause({required this.action, this.target = const []});

  /// The conflict-target columns (the unique index / constraint columns).
  ///
  /// May be empty for a bare `ON CONFLICT DO NOTHING`.
  final List<Column<dynamic, dynamic>> target;

  /// What to do when a conflict occurs.
  final ConflictAction action;

  @override
  String render(RenderContext context) {
    return [
      'ON CONFLICT',
      if (target.isNotEmpty)
        '(${target.map((c) => context.escapeName(c.name)).join(', ')})',
      switch (action) {
        DoNothing() => 'DO NOTHING',
        DoUpdate(:final assignments) => '''
DO UPDATE SET ${UpdateSetClause(UpdateableResult(assignments)).render(context)}''',
      },
    ].join(' ');
  }
}

/// Adds `onConflict(...)` to a Postgres insert.
extension PostgresOnConflictExtension<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  /// Append an `ON CONFLICT [(target)] DO ...` clause.
  ///
  /// ```dart
  /// db.insert(into: users).values([u])
  ///     .onConflict([users.email], const DoNothing());
  ///
  /// db.insert(into: users).values([u])
  ///     .onConflict([users.email], DoUpdate([users.name.to('updated')]));
  /// ```
  InsertWithValuesBuilder<S, R, void> onConflict(
    List<Column<dynamic, dynamic>> target,
    ConflictAction action,
  ) {
    // Between the body (2000) and any trailing RETURNING (body + 5000).
    return withClause(
      InsertSlot.body + 1000,
      (_) => OnConflictClause(target: target, action: action),
      InsertWithValuesBuilder.new,
    );
  }
}
