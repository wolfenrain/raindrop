import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/dialect.dart';

/// Serves [generator] over the isolate command protocol the CLI speaks.
///
/// Sends a command port back over [sendPort], then answers `generate`
/// messages until the returned [ReceivePort] is closed.
///
/// A driver's DDL entrypoint is the only place this belongs:
///
/// ```dart
/// void main(List<String> args, SendPort sendPort) =>
///     serveDdlGenerator(MyDdlGenerator(), sendPort);
/// ```
ReceivePort serveDdlGenerator(DdlGenerator generator, SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final replyPort = message['replyPort'] as SendPort;
      final action = message['action'] as String? ?? 'generate';

      try {
        switch (action) {
          case 'generate':
            final sql = generator.generate(
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
      } on Object catch (e, st) {
        replyPort.send({'success': false, 'error': '$e\n$st'});
      }
    }
  });

  return receivePort;
}

/// {@template ddl_generator}
/// Abstract interface for generating DDL statements from diff operations.
///
/// Each database dialect provides its own implementation, and its package's
/// `lib/ddl.dart` defines a main method serving it so the CLI can execute it
/// dynamically:
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
