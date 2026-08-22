import 'package:raindrop/dialect.dart';

/// The row that failed to insert, usable in `doUpdate` assignments:
///
/// ```dart
/// .onConflict([users.email]).doUpdate([users.age.to(excluded(users.age))])
/// // ... DO UPDATE SET "age" = "excluded"."age"
/// ```
Excluded<V> excluded<V>(ColumnType<V> column) => Excluded<V>(column);

/// {@template excluded}
/// A reference to a column of the `excluded` row, the row that an insert
/// tried and failed to store.
/// {@endtemplate}
class Excluded<V> extends Expression<V> {
  /// {@macro excluded}
  const Excluded(this.column);

  /// The column whose would-be-inserted value is referenced.
  final ColumnType<V> column;

  @override
  ColumnTransformer<V, Object?>? get transformer => column.transformer;

  @override
  SQL build() => SQL([_ExcludedRef(column)]);
}

class _ExcludedRef extends Clause {
  const _ExcludedRef(this.column);

  final Column<dynamic, Object?> column;

  @override
  String render(RenderContext context) =>
      '${context.escapeName('excluded')}.${context.escapeName(column.name)}';
}

/// Adds `onConflict(...)` to a SQLite insert, opening an upsert clause that
/// reads in SQL order:
///
/// ```dart
/// db.insert(into: users).values([u])
///     .onConflict([users.email])
///     .doUpdate([users.age.to(excluded(users.age))]);
///
/// db.insert(into: users).values([u]).onConflict().doNothing();
/// ```
extension SQLiteOnConflictExtension<S extends Schema<R>, R>
    on InsertWithValuesBuilder<S, R, void> {
  /// Open an `ON CONFLICT [(target)]` clause.
  ///
  /// [target] names the conflicting unique index or constraint columns, and
  /// may only be omitted when the clause is closed with
  /// [OnConflictBuilder.doNothing].
  OnConflictBuilder<S, R> onConflict([
    List<Column<dynamic, dynamic>> target = const [],
  ]) =>
      OnConflictBuilder._(this, target);
}

/// {@template on_conflict_builder}
/// An opened `ON CONFLICT [(target)] [WHERE ...]` clause, closed by
/// [doNothing] or [doUpdate].
/// {@endtemplate}
class OnConflictBuilder<S extends Schema<R>, R> {
  const OnConflictBuilder._(this._insert, this._target, [this._targetWhere]);

  final InsertWithValuesBuilder<S, R, void> _insert;
  final List<Column<dynamic, dynamic>> _target;
  final Filter? _targetWhere;

  /// Narrow the [_target] with `WHERE`, matching a partial unique index.
  OnConflictBuilder<S, R> where(Filter where) {
    if (_target.isEmpty) {
      throw StateError(
        'ON CONFLICT WHERE narrows a conflict target, so onConflict() must '
        'be given one.',
      );
    }
    return OnConflictBuilder._(_insert, _target, where);
  }

  /// Close the clause with `DO NOTHING`, skipping the conflicting row.
  InsertWithValuesBuilder<S, R, void> doNothing() =>
      _close(const RawSQL('DO NOTHING'));

  /// Close the clause with `DO UPDATE SET ...`, updating the existing row
  /// with [assignments], optionally only where [where] holds.
  ///
  /// Reference the row that failed to insert with [excluded].
  InsertWithValuesBuilder<S, R, void> doUpdate(
    List<Updateable<dynamic>> assignments, {
    Filter? where,
  }) {
    if (_target.isEmpty) {
      throw StateError(
        'DO UPDATE requires a conflict target, give onConflict() the unique '
        'columns the insert can conflict on.',
      );
    }
    return _close(
      SQL([
        const RawSQL('DO UPDATE SET'),
        UpdateSetClause(UpdateableResult<void>(assignments)),
        if (where != null) ...[const RawSQL('WHERE'), where],
      ]),
    );
  }

  InsertWithValuesBuilder<S, R, void> _close(Object action) {
    // Between the body (2000) and any trailing RETURNING (body + 5000).
    return _insert.withClause(
      InsertSlot.body + 1000,
      (_) => OnConflictClause(
        target: _target,
        targetWhere: _targetWhere,
        action: action,
      ),
      InsertWithValuesBuilder.new,
    );
  }
}

/// An `ON CONFLICT [(target)] [WHERE ...] DO ...` clause of a SQLite insert.
class OnConflictClause extends Clause {
  /// Creates a conflict clause for the given [target] and [action].
  const OnConflictClause({
    required this.action,
    this.target = const [],
    this.targetWhere,
  });

  /// The conflict-target columns (the unique index / constraint columns).
  ///
  /// May be empty for a bare `ON CONFLICT DO NOTHING`.
  final List<Column<dynamic, dynamic>> target;

  /// The partial-index predicate narrowing [target], if any.
  final Filter? targetWhere;

  /// The rendered-SQL action closing the clause.
  final Object action;

  @override
  String render(RenderContext context) {
    return ExpressionClause(
      SQL([
        const RawSQL('ON CONFLICT'),
        if (target.isNotEmpty) target,
        if (targetWhere case final targetWhere?) ...[
          const RawSQL('WHERE'),
          targetWhere,
        ],
        action,
      ]),
      singleTable: true,
    ).render(context);
  }
}
