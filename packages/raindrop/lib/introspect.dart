import 'package:raindrop/dialect.dart';

/// Snapshot format version. Must match `SchemaSnapshot.currentVersion` in
/// `raindrop_cli`, the two packages cannot see each other, and the CLI reads
/// this value back out of the JSON.
const String snapshotFormatVersion = '1';

/// Stand-in for the identity fields. `generate` overwrites both with a fresh
/// id and the journal's previous id, but they must be present and non-null for
/// the CLI to parse the document at all.
const String _placeholderId = '00000000-0000-0000-0000-000000000000';

/// Describes every table reachable from [schemas], as the JSON the CLI's
/// `SchemaSnapshot.fromJson` accepts.
///
/// [schemas] must be listed explicitly: a table registers itself when its
/// top-level `final` is first read, and Dart initialises those lazily, so
/// importing a schema library constructs nothing.
Map<String, Object?> buildSnapshot(
  List<Schema<dynamic>> schemas, {
  required SqlDialect dialect,
  required String dialectName,
}) {
  final tables = <String, Object?>{};
  final indexes = <String, Object?>{};

  for (final schema in schemas) {
    final table = schema.$;
    // An alias is a view onto another table, never its own definition.
    if (table.alias != null) continue;
    if (table.dialect != dialectName) continue;

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

  return {
    'version': snapshotFormatVersion,
    'dialect': dialectName,
    'id': _placeholderId,
    'prevId': _placeholderId,
    'tables': tables,
    'indexes': indexes,
  };
}

Map<String, Object?> _table(Table<dynamic, dynamic> table, SqlDialect dialect) {
  final columns = <String, Object?>{};
  for (final column in table.columns) {
    columns[column.name] = _column(table, column, dialect);
  }

  return {
    'name': table.name,
    'columns': columns,
    if (table.checks.isNotEmpty)
      'checks': {
        for (final check in table.checks) check.name: _checkSql(check, dialect),
      },
  };
}

/// A constraint's SQL, rendered from its predicate.
String _checkSql(Check check, SqlDialect dialect) =>
    renderPredicate(check.predicate, dialect);

Map<String, Object?> _column(
  Table<dynamic, dynamic> table,
  Column<dynamic, dynamic> column,
  SqlDialect dialect,
) {
  final sqlType = column.sqlType;
  if (sqlType == null) {
    throw StateError(
      'column "${table.name}.${column.name}" has no sqlType, so no migration '
      'can declare it. Column builders must pass one',
    );
  }

  final reference = column.foreignKeyReference;
  return {
    'name': column.name,
    'type': sqlType,
    'primaryKey': column.isPrimaryKey,
    'isNullable': column.isNullable,
    if (column.autoIncrement) 'autoIncrement': true,
    if (column.defaultValue case final defaultValue?)
      'default': switch (defaultValue) {
        final Expression<dynamic> expression =>
          renderPredicate(expression.build(), dialect),
        _ => dialect.escapeLiteral(column.encode(defaultValue)),
      },
    if (reference != null)
      'foreignKey': {
        'referencedTable': reference.referencedTable,
        'referencedColumn': reference.referencedColumnName,
        if (reference.onDelete case final onDelete?)
          'onDelete': _referentialActionSql(onDelete),
        if (reference.onUpdate case final onUpdate?)
          'onUpdate': _referentialActionSql(onUpdate),
      },
  };
}

/// The ANSI keyword for a referential action.
String _referentialActionSql(ReferentialAction action) => switch (action) {
      ReferentialAction.cascade => 'CASCADE',
      ReferentialAction.setNull => 'SET NULL',
      ReferentialAction.setDefault => 'SET DEFAULT',
      ReferentialAction.restrict => 'RESTRICT',
      ReferentialAction.noAction => 'NO ACTION',
    };

Map<String, Object?> _index(Index index, SqlDialect dialect) {
  if (index.columns.isEmpty) {
    throw StateError('index "${index.name}" covers no columns');
  }

  final where = index.where;
  return {
    'name': index.name,
    'tableName': index.columns.first.table.name,
    'columns': [for (final column in index.columns) column.name],
    'isUnique': index.isUnique,
    if (where != null) 'where': renderPredicate(where, dialect),
  };
}

/// Renders [filter] as SQL that can sit in a schema: no bind parameters, and
/// no table qualifier.
String renderPredicate(Filter filter, SqlDialect dialect) =>
    FilterClause(filter, singleTable: true)
        .render(LiteralRenderContext(dialect));
