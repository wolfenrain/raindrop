import 'package:meta/meta.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/rendering/clause.dart';

/// The rows a whole-row select returns, usable where its table is.
///
/// ```dart
/// final active =
///     db.select().from(users).where(users.isActive.isTrue()).derived();
/// await db.select(users.name).from(active).where(users.age.greaterThan(30));
/// // FROM (SELECT ... FROM "users" WHERE ...) AS "users" WHERE "age" > $1
/// ```
///
/// Pairs with `subquery()`, which does this in expression position.
extension DerivedWholeRow<S extends Schema<R>, R> on WholeRowFromBuilder<S, R> {
  /// {@macro derived}
  S derived() {
    final from = config.get<Table<S, R>>(#from);
    if (from == null) {
      throw StateError('A derived table needs a query that selects FROM one.');
    }
    return from.asDerived(compileEmbedded()).schema;
  }
}

/// What a projection needs before it can back a derived table: a name for
/// every output, and the statement that produces them.
///
/// Used by the generated `DerivedN` extensions, not meant to be called
/// directly.
@internal
class PreparedDerived<V> {
  /// {@macro prepared_derived}
  const PreparedDerived(this.query, this.names, this.sources);

  /// The compiled inner statement.
  final Query<V> query;

  /// The output name of each projected item, in order.
  final List<String> names;

  /// What each item was built from, so a column can inherit its transformer.
  final List<Selectable<dynamic>> sources;
}

/// Names every output of [builder]'s projection and compiles it.
///
/// A `Column` already has a name and an aliased expression already has one.
/// A bare expression does NOT, it renders as anonymous SQL, and the outer
/// query then references a column that does not exist. So this does not merely
/// record names, it **rewrites the projection** to emit them.
@internal
PreparedDerived<V> prepareDerived<V>(
  SelectFromBuilder<Schema<dynamic>, dynamic, V> builder,
) {
  final shape = builder.compileEmbedded().shape;
  final original = switch (shape) {
    final SelectableResult<dynamic> result => result.selected,
    final Selectable<dynamic> single => [single],
  };

  // Names already spoken for, so a generated one can never shadow a real one.
  final taken = <String>{};
  for (final item in original) {
    switch (item) {
      // Put before the plain Column case, which it also matches.
      case final ColumnAlias<dynamic, dynamic> aliased:
        taken.add(aliased.alias);
      case final Column<dynamic, dynamic> column:
        taken.add(column.name);
      case final AliasedExpression<dynamic> aliased:
        taken.add(aliased.alias);
      default:
        break;
    }
  }

  final names = <String>[];
  final renamed = <Selectable<dynamic>>[];
  for (var i = 0; i < original.length; i++) {
    switch (original[i]) {
      case final ColumnAlias<dynamic, dynamic> aliased:
        names.add(aliased.alias);
        renamed.add(aliased);
      case final Column<dynamic, dynamic> column:
        names.add(column.name);
        renamed.add(column);
      case final AliasedExpression<dynamic> aliased:
        names.add(aliased.alias);
        renamed.add(aliased);
      case final Expression<dynamic> expression:
        // Generated into the gap, and never over a name already in use.
        var generated = 'c$i';
        for (var n = i; taken.contains(generated); n++) {
          generated = 'c$n';
        }
        taken.add(generated);
        names.add(generated);
        renamed.add(expression.as(generated));
      case final Selectable<dynamic> other:
        throw UnsupportedError(
          '''
A derived table cannot project ${other.runtimeType}. Select columns or expressions.''',
        );
    }
  }

  final rewritten = SelectFromBuilder<Schema<dynamic>, dynamic, V>(
    builder.executor,
    config: builder.config.copyWith({
      #selecting:
          original.length == 1 ? renamed.single : SelectableResult<V>(renamed),
    }),
  );

  return PreparedDerived<V>(rewritten.compileEmbedded(), names, original);
}

/// The default name for a derived table, taken from what it selects from.
///
/// Deterministic on purpose, a counter would make the same query render
/// differently depending on what was built before it, which would make golden
/// tests depend on execution order.
@internal
String defaultDerivedName(QueryConfig config) {
  final from = config.from;
  return from == null ? 'derived' : '${from.name}_d';
}

/// One synthetic column of a derived table.
///
/// [read] pulls this position out of the record row. The transformer is taken
/// from whatever the projection selected, so reading the column decodes back to
/// the domain type rather than the driver's form.
@internal
Column<R, W> derivedColumn<R, W>(
  SchemaBuilder<R> $,
  PreparedDerived<dynamic> prepared,
  int index,
  W Function(R) read,
) {
  final source = prepared.sources[index];
  final column = Column<R, W>(
    $.table,
    prepared.names[index],
    valueOf: read,
    isNullable: null is W,
    transformer: switch (source) {
      final SqlOperand<dynamic> operand =>
        operand.transformer as ColumnTransformer<W, Object?>?,
      _ => null,
    },
  );
  $.table.columns.add(column as Column<R, dynamic>);
  return column;
}
