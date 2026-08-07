import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';

/// {@template ddl_generator}
/// Abstract interface for generating DDL statements from diff operations.
///
/// Each database dialect (PostgreSQL, SQLite, etc.) should provide its own
/// implementation of this interface and define a main method in the file so
/// it can be dynamically executed by the DDL runtime.
/// ```
/// void main(List<String> args, SendPort sendPort) => MyDdlGenerator(sendPort);
///
/// class MyDdlGenerator extends DdlGenerator {
///   MyDdlGenerator(super.sendPort) : super(dialect: const MyDialect());
///
///   ...
/// }
/// ```
/// {@endtemplate}
abstract class DdlGenerator {
  /// {@macro ddl_generator}
  DdlGenerator(SendPort sendPort, {required this.dialect}) {
    final receivePort = _receivePort = ReceivePort();
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

              replyPort.send({'success': true, 'sql': sql});
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

  late final ReceivePort _receivePort;

  /// Closes the command port.
  void dispose() => _receivePort.close();

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
        CreateTable(:final table) => createTable(table),
        DropTable(:final tableName) => dropTable(tableName),
        final AlterTable alter => alterTable(alter),
        CreateIndex(:final index) => createIndex(index),
        DropIndex(:final indexName) => dropIndex(indexName),
      };

  String _nonBlank(DiffOperation operation, String sql) {
    if (sql.trim().isEmpty) {
      throw StateError('${operation.describe()} produced no SQL.');
    }
    return sql;
  }

  /// Generates a CREATE TABLE statement.
  String createTable(TableInfo table);

  /// Generates a DROP TABLE statement.
  String dropTable(String tableName);

  /// Expresses every change [operation] carries, column changes, checks,
  /// and this table's index changes.
  String alterTable(AlterTable operation);

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
