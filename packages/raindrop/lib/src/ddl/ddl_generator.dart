import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';

/// {@template ddl_generator}
/// Abstract interface for generating DDL statements from diff operations.
///
/// Each database dialect (PostgreSQL, SQLite, etc.) should provide its own
/// implementation of this interface and define a main method in the file so
/// it can be dynamically executed by the DDL runtime.
/// ```
/// void main(List<String> args, SendPort sendPort) => MyDdqlGenerator(sendPort);
///
/// class MyDdqlGenerator extends DdlGenerator {
///   MyDdqlGenerator(super.sendPort) : super(dialect: const MyDialect());
///
///   ...
/// }
/// ```
/// {@endtemplate}
abstract class DdlGenerator {
  /// {@macro ddl_generator}
  DdlGenerator(SendPort sendPort, {required this.dialect}) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is Map<String, dynamic>) {
        final replyPort = message['replyPort'] as SendPort;
        final action = message['action'] as String? ?? 'generate';

        try {
          switch (action) {
            case 'generate':
              final sql = generate(
                (message['operations'] as List<dynamic>)
                    .map((o) => DiffOperation.fromMap((o as Map).cast()))
                    .toList(),
              );

              replyPort.send({
                'success': true,
                'sql': sql,
                'warnings': List<String>.from(_generationWarnings),
              });
            default:
              replyPort.send(
                {'success': false, 'error': 'Unknown action: $action'},
              );
          }
        } catch (e, st) {
          replyPort.send({'success': false, 'error': '$e\n$st'});
        }
      }
    });
  }

  /// The SQL dialect used by this generator.
  final SqlDialect dialect;

  final List<String> _generationWarnings = [];

  /// Records a non-fatal issue for the host (e.g. CLI) to surface.
  ///
  /// Cleared at the start of each [generate] call.
  void warn(String message) => _generationWarnings.add(message);

  /// Generates SQL DDL statements from a list of diff operations.
  String generate(List<DiffOperation> operations) {
    _generationWarnings.clear();
    return [
      for (final op in operations)
        switch (op) {
          CreateTable(:final tableName, :final columns) =>
            createTable(tableName, columns),
          RenameTable(:final oldName, :final newName) =>
            renameTable(oldName, newName),
          DropTable(:final tableName) => dropTable(tableName),
          AddColumn(:final tableName, :final column) =>
            addColumn(tableName, column),
          RenameColumn(:final tableName, :final oldName, :final newName) =>
            renameColumn(tableName, oldName, newName),
          DropColumn(:final tableName, :final columnName) =>
            dropColumn(tableName, columnName),
          AlterColumn(
            :final tableName,
            :final oldColumn,
            :final newColumn,
            :final tableColumns,
          ) =>
            alterColumn(tableName, oldColumn, newColumn, tableColumns),
          CreateIndex(:final index) => createIndex(index),
          DropIndex(:final indexName) => dropIndex(indexName),
        },
    ].join('\n\n');
  }

  /// Generates a CREATE TABLE statement.
  String createTable(String tableName, List<ColumnInfo> columns);

  /// Generate SQL to rename an existing table.
  String renameTable(String oldName, String newName);

  /// Generates a DROP TABLE statement.
  String dropTable(String tableName);

  /// Generates an ADD COLUMN statement.
  String addColumn(String tableName, ColumnInfo column);

  /// Generate SQL to rename an existing column.
  String renameColumn(String tableName, String oldName, String newName);

  /// Generates a DROP COLUMN statement.
  String dropColumn(String tableName, String columnName);

  /// Generates an ALTER COLUMN statement (or equivalent).
  ///
  /// [tableColumns] is the full column list after applying this single change,
  /// in pre-migration column order (PostgreSQL generators may ignore it).
  String alterColumn(
    String tableName,
    ColumnInfo oldColumn,
    ColumnInfo newColumn,
    List<ColumnInfo> tableColumns,
  );

  /// Generates a CREATE INDEX statement.
  String createIndex(IndexInfo index);

  /// Generates a DROP INDEX statement.
  String dropIndex(String indexName);

  /// Gets the SQL type string for a column.
  String getColumnType(ColumnInfo column);

  /// Escape [name] through the [dialect].
  ///
  /// Allows for overriding if necessary.
  String escapeName(String name) => dialect.escapeName(name);
}
