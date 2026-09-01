import 'package:raindrop/dialect.dart';
import 'package:raindrop/src/snapshot.dart';

/// Describes every table and index reachable from [schemas].
///
/// [schemas] must be listed explicitly: a table registers itself when its
/// top-level `final` is first read, and Dart initialises those lazily, so
/// importing a schema library constructs nothing.
///
/// [dialectName] selects which tables count and defaults to the [dialect]'s
/// own [SqlDialect.name], pass it explicitly only when the tables carry a
/// different tag than the rendering dialect.
SchemaSnapshot buildSnapshot(
  List<Schema<dynamic>> schemas, {
  required SqlDialect dialect,
  String? dialectName,
}) {
  dialectName ??= dialect.name;
  final tables = <String, TableSnapshot>{};
  final indexes = <String, IndexSnapshot>{};

  for (final schema in schemas) {
    final table = schema.$;
    // An alias is a view onto another table, never its own definition.
    if (table.alias != null) continue;
    if (table.dialect?.name != dialectName) continue;

    if (tables.containsKey(table.name)) {
      throw StateError('two tables are both named "${table.name}"');
    }
    tables[table.name] = _table(table, dialect);

    for (final index in table.indexes) {
      if (indexes.containsKey(index.name)) {
        throw StateError('two indexes are both named "${index.name}"');
      }
      indexes[index.name] = _index(index, dialect);
    }
  }

  return SchemaSnapshot(
    dialect: dialectName,
    tables: tables,
    indexes: indexes,
  );
}

TableSnapshot _table(Table<dynamic, dynamic> table, SqlDialect dialect) {
  final columns = <String, ColumnSnapshot>{};
  for (final column in table.columns) {
    columns[column.name] = _column(table, column, dialect);
  }

  return TableSnapshot(
    name: table.name,
    columns: columns,
    checks: {
      for (final check in table.checks) check.name: _checkSql(check, dialect),
    },
  );
}

/// A constraint's SQL, rendered from its predicate.
String _checkSql(Check check, SqlDialect dialect) =>
    renderPredicate(check.predicate, dialect);

ColumnSnapshot _column(
  Table<dynamic, dynamic> table,
  Column<dynamic, dynamic> column,
  SqlDialect dialect,
) {
  final sqlType = column.sqlType;
  if (sqlType == null) {
    throw StateError(
      '''
column "${table.name}.${column.name}" has no sqlType, so no migration can declare it. Column builders must pass one''',
    );
  }

  final reference = column.foreignKeyReference;
  return ColumnSnapshot(
    name: column.name,
    type: sqlType,
    primaryKey: column.isPrimaryKey,
    isNullable: column.isNullable,
    autoIncrement: column.autoIncrement,
    defaultValue: switch (column.defaultValue) {
      null => null,
      final Expression<dynamic> expression =>
        renderPredicate(expression.build(), dialect),
      final defaultValue => dialect.escapeLiteral(column.encode(defaultValue)),
    },
    foreignKey: reference == null
        ? null
        : ForeignKeySnapshotRef(
            referencedTable: reference.referencedTable,
            referencedColumn: reference.referencedColumnName,
            onDelete: switch (reference.onDelete) {
              final onDelete? => _referentialActionSql(onDelete),
              _ => null,
            },
            onUpdate: switch (reference.onUpdate) {
              final onUpdate? => _referentialActionSql(onUpdate),
              _ => null,
            },
          ),
  );
}

/// The ANSI keyword for a referential action.
String _referentialActionSql(ReferentialAction action) => switch (action) {
      ReferentialAction.cascade => 'CASCADE',
      ReferentialAction.setNull => 'SET NULL',
      ReferentialAction.setDefault => 'SET DEFAULT',
      ReferentialAction.restrict => 'RESTRICT',
      ReferentialAction.noAction => 'NO ACTION',
    };

IndexSnapshot _index(Index index, SqlDialect dialect) {
  if (index.columns.isEmpty) {
    throw StateError('index "${index.name}" covers no columns');
  }

  final where = index.where;
  return IndexSnapshot(
    name: index.name,
    tableName: index.columns.first.table.name,
    columns: [for (final column in index.columns) column.name],
    isUnique: index.isUnique,
    where: where == null ? null : renderPredicate(where, dialect),
  );
}

/// Renders [filter] as SQL that can sit in a schema: no bind parameters, and
/// no table qualifier.
String renderPredicate(Filter filter, SqlDialect dialect) =>
    FilterClause(filter, singleTable: true)
        .render(LiteralRenderContext(dialect));
