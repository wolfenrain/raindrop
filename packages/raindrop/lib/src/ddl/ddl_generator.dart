import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';

/// {@template ddl_generator}
/// Abstract interface for generating DDL statements from diff operations.
///
/// Each database dialect provides its own implementation, and its package's
/// `lib/ddl.dart` defines a main method serving it (through
/// `package:raindrop/ddl_server.dart`) so the CLI can execute it dynamically:
/// ```dart
/// void main(List<String> args, SendPort sendPort) =>
///     serveDdlGenerator(MyDdlGenerator(), sendPort);
///
/// class MyDdlGenerator extends DdlGenerator {
///   const MyDdlGenerator() : super(dialect: const MyDialect());
///
///   ...
/// }
/// ```
/// {@endtemplate}
abstract class DdlGenerator {
  /// {@macro ddl_generator}
  const DdlGenerator({required this.dialect});

  /// The SQL dialect used by this generator.
  final SqlDialect dialect;

  /// Generates SQL DDL statements from a list of diff operations.
  ///
  /// Overridable so a dialect can validate ACROSS operations (e.g. SQLite
  /// rejects a rebuild whose dependent table is itself altered in the same
  /// run), overrides should still delegate here for the per-operation work.
  String generate(List<DiffOperation> operations) {
    return [
      for (final op in operations) _nonBlank(op, render(op)),
    ].join('\n\n');
  }

  /// Renders a single operation through the dialect's methods.
  String render(DiffOperation operation) => switch (operation) {
        CreateTable(:final table, :final ifNotExists) =>
          createTable(table, ifNotExists: ifNotExists),
        DropTable(:final tableName) => dropTable(tableName),
        final AlterTable alter => alterTable(alter),
        CreateIndex(:final index, :final ifNotExists) =>
          createIndex(index, ifNotExists: ifNotExists),
        DropIndex(:final indexName) => dropIndex(indexName),
      };

  String _nonBlank(DiffOperation operation, String sql) {
    if (sql.trim().isEmpty) {
      throw StateError('${operation.describe()} produced no SQL.');
    }
    return sql;
  }

  /// Generates a CREATE TABLE statement.
  ///
  /// With [ifNotExists], an existing table with this name is left alone.
  String createTable(TableInfo table, {bool ifNotExists = false});

  /// Generates a DROP TABLE statement.
  String dropTable(String tableName);

  /// Expresses every change [operation] carries, column changes, checks,
  /// and this table's index changes.
  String alterTable(AlterTable operation);

  /// Generates a CREATE INDEX statement.
  ///
  /// With [ifNotExists], an existing index with this name is left alone.
  String createIndex(IndexInfo index, {bool ifNotExists = false});

  /// Generates a DROP INDEX statement.
  String dropIndex(String indexName);

  /// Gets the SQL type string for a column.
  String getColumnType(ColumnInfo column);

  /// Escape [name] through the [dialect].
  ///
  /// Allows for overriding if necessary.
  String escapeName(String name) => dialect.escapeName(name);
}
