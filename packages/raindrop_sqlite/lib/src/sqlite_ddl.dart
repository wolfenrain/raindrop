import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop_sqlite/src/sqlite_dialect.dart';

void main(List<String> args, SendPort sendPort) => SQLiteDdlGenerator(sendPort);

/// {@template sqlite_ddl_generator}
/// DDL generator for SQLite.
/// {@endtemplate}
class SQLiteDdlGenerator extends DdlGenerator {
  /// {@macro sqlite_ddl_generator}
  SQLiteDdlGenerator(super.sendPort) : super(dialect: const SQLiteDialect());

  @override
  String createTable(String tableName, List<ColumnInfo> columns) {
    final columnDefs = columns.map(_columnDefinition).join(',\n  ');
    return 'CREATE TABLE ${escapeName(tableName)} (\n  $columnDefs\n);';
  }

  @override
  String renameTable(String oldName, String newName) {
    return 'ALTER TABLE ${escapeName(oldName)} RENAME TO ${escapeName(newName)};';
  }

  @override
  String dropTable(String tableName) {
    return 'DROP TABLE ${escapeName(tableName)};';
  }

  @override
  String addColumn(String tableName, ColumnInfo column) {
    final effective = _sqliteEffectiveColumnForAdd(tableName, column);
    return 'ALTER TABLE ${escapeName(tableName)} ADD COLUMN ${_columnDefinition(effective)};';
  }

  @override
  String renameColumn(String tableName, String oldName, String newName) {
    return 'ALTER TABLE ${escapeName(tableName)} RENAME COLUMN ${escapeName(oldName)} TO ${escapeName(newName)};';
  }

  @override
  String dropColumn(String tableName, String columnName) {
    return 'ALTER TABLE ${escapeName(tableName)} DROP COLUMN ${escapeName(columnName)};';
  }

  @override
  String alterColumn(
    String tableName,
    ColumnInfo oldColumn,
    ColumnInfo newColumn,
    List<ColumnInfo> tableColumns, {
    List<IndexInfo> indexes = const [],
  }) {
    assert(
      oldColumn.name == newColumn.name,
      'SQLite rebuild expects in-place column alterations',
    );
    assert(tableColumns.isNotEmpty);

    // SQLite has no ALTER COLUMN for type / nullability / default; rebuild.
    final table = escapeName(tableName);
    final column = escapeName(newColumn.name);
    final temp = escapeName('${tableName}_raindrop_rebuild');
    final defs = tableColumns.map(_columnDefinition).join(',\n  ');

    final steps = <String>[];
    if (oldColumn.isNullable && !newColumn.isNullable) {
      final backfillValue = _sqliteBackfillExpressionForNotNull(
        tableName,
        newColumn,
      );
      steps.add(
        'UPDATE $table SET $column = $backfillValue WHERE $column IS NULL;',
      );
    }

    // DROP TABLE fails when foreign keys reference this table (or vice versa)
    // unless enforcement is disabled for the rebuild.
    steps.add('PRAGMA foreign_keys=OFF;');
    steps.addAll([
      'CREATE TABLE $temp (\n  $defs\n);',
      'INSERT INTO $temp SELECT * FROM $table;',
      'DROP TABLE $table;',
      'ALTER TABLE $temp RENAME TO $table;',
    ]);
    for (final index in indexes) {
      steps.add(createIndex(index));
    }
    steps.add('PRAGMA foreign_keys=ON;');
    return steps.join('\n');
  }

  @override
  String createIndex(IndexInfo index) {
    final unique = index.isUnique ? 'UNIQUE ' : '';
    final cols = index.columns.map(escapeName).join(', ');
    return 'CREATE ${unique}INDEX ${escapeName(index.name)} '
        'ON ${escapeName(index.tableName)} ($cols);';
  }

  @override
  String dropIndex(String indexName) {
    return 'DROP INDEX ${escapeName(indexName)};';
  }

  @override
  String getColumnType(ColumnInfo column) => column.type;

  String _columnDefinition(ColumnInfo column) {
    final parts = <String>[
      escapeName(column.name),
      getColumnType(column),
    ];

    if (column.primaryKey) {
      parts.add('PRIMARY KEY');
      if (column.autoIncrement) {
        parts.add('AUTOINCREMENT');
      }
    }

    if (!column.isNullable && !column.primaryKey) {
      parts.add('NOT NULL');
    }

    if (column.defaultValue != null) {
      parts.add('DEFAULT ${column.defaultValue}');
    }

    if (column.foreignKey case final fk?) {
      parts.add(
        'REFERENCES ${escapeName(fk.referencedTable)}(${escapeName(fk.referencedColumn)})',
      );
      if (fk.onDelete != null) parts.add('ON DELETE ${fk.onDelete}');
      if (fk.onUpdate != null) parts.add('ON UPDATE ${fk.onUpdate}');
    }

    return parts.join(' ');
  }

  /// Applies SQLite ADD COLUMN rules: NOT NULL requires a non-NULL DEFAULT when
  /// rows may exist. Infers a constant DEFAULT from [ColumnInfo.type] when absent.
  ColumnInfo _sqliteEffectiveColumnForAdd(String tableName, ColumnInfo column) {
    if (column.isNullable ||
        _sqliteDefaultExpressionIsNonNull(column.defaultValue)) {
      return column;
    }

    final inferredExpr = _inferSqliteNotNullDefaultExpression(column);
    if (inferredExpr == null) {
      throw StateError(
        'SQLite cannot ALTER TABLE ADD COLUMN "${column.name}" on "$tableName" '
        'as NOT NULL without a non-NULL DEFAULT. No DEFAULT was given and the '
        'type "${column.type}" is not supported for automatic inference; add an '
        'explicit SQL default in your schema.',
      );
    }

    warn(
      'SQLite ADD COLUMN "${column.name}" on "$tableName": NOT NULL with no '
      'DEFAULT; inferred constant DEFAULT $inferredExpr from SQL '
      'type "${column.type}". ${_sqliteAddColumnConstantDefaultNote()} Prefer '
      'setting an explicit literal DEFAULT or using a table-rebuild migration '
      'if you need a non-constant default.',
    );

    return ColumnInfo(
      name: column.name,
      type: column.type,
      isNullable: column.isNullable,
      primaryKey: column.primaryKey,
      autoIncrement: column.autoIncrement,
      defaultValue: inferredExpr,
      foreignKey: column.foreignKey,
    );
  }

  String _sqliteAddColumnConstantDefaultNote() =>
      'SQLite only accepts constant DEFAULT values on ADD COLUMN.';

  /// SQL value expression for backfilling NULLs before NOT NULL rebuild.
  String _sqliteBackfillExpressionForNotNull(
    String tableName,
    ColumnInfo column,
  ) {
    if (_sqliteDefaultExpressionIsNonNull(column.defaultValue)) {
      return column.defaultValue!;
    }

    if (column.primaryKey && _sqliteTextAffinity(column.type)) {
      warn(
        'SQLite NOT NULL backfill for PRIMARY KEY "${column.name}" on '
        '"$tableName": no explicit DEFAULT; using lower(hex(randomblob(8))) '
        'per row. Set an explicit literal DEFAULT on the column if you need a '
        'fixed sentinel instead.',
      );
      return 'lower(hex(randomblob(8)))';
    }

    final inferred = _inferSqliteNotNullDefaultExpression(column);
    if (inferred == null) {
      throw StateError(
        'SQLite cannot set "${column.name}" on "$tableName" to NOT NULL: '
        'existing NULL values need a backfill value but no DEFAULT is defined '
        'and type "${column.type}" has no inferred constant. Add an explicit '
        'SQL default on the column in your schema.',
      );
    }

    warn(
      'SQLite NOT NULL backfill for "${column.name}" on "$tableName": no '
      'explicit DEFAULT; inferred constant $inferred from SQL type '
      '"${column.type}". Prefer setting an explicit literal DEFAULT on the '
      'column.',
    );
    return inferred;
  }

  /// Whether [defaultExpression] is present and not trivially SQL NULL.
  bool _sqliteDefaultExpressionIsNonNull(String? defaultExpression) {
    if (defaultExpression == null) return false;
    var expr = defaultExpression.trim();
    if (expr.isEmpty) return false;
    while (expr.startsWith('(') && expr.endsWith(')')) {
      expr = expr.substring(1, expr.length - 1).trim();
    }
    return expr.toUpperCase() != 'NULL';
  }
}

/// SQL DEFAULT expression (without `DEFAULT` keyword), or null if unknown.
String? _inferSqliteNotNullDefaultExpression(ColumnInfo column) {
  final sqlType = column.type.trim().toUpperCase();

  if (_sqliteBlobAffinity(sqlType)) {
    return null;
  }

  if (_sqliteIntegerAffinity(sqlType)) {
    return '0';
  }

  if (_sqliteRealAffinity(sqlType)) {
    return '0.0';
  }

  if (_sqliteTextAffinity(sqlType)) {
    return "''";
  }

  if (sqlType == 'NUMERIC' || sqlType == 'BOOLEAN' || sqlType == 'BOOL') {
    return '0';
  }

  return null;
}

bool _sqliteBlobAffinity(String sqlType) {
  final u = sqlType.toUpperCase();
  return u == 'BLOB' || u.contains('BINARY');
}

/// INTEGER affinity (SQLite rules): type name contains "INT".
bool _sqliteIntegerAffinity(String sqlType) =>
    sqlType.toUpperCase().contains('INT');

bool _sqliteRealAffinity(String sqlType) {
  final u = sqlType.toUpperCase();
  return u == 'REAL' || u.contains('FLOA') || u.contains('DOUB');
}

bool _sqliteTextAffinity(String sqlType) {
  final u = sqlType.toUpperCase();
  return u.contains('CHAR') || u == 'TEXT' || u == 'CLOB' || u == 'STRING';
}
