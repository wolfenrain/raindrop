/// {@template database_result}
/// The result from the database on any given query.
/// {@endtemplate}
class DatabaseResult {
  /// {@macro database_result}
  const DatabaseResult({
    required this.columns,
    required this.rows,
    required this.rowsAffected,
    required this.lastInsertedRowId,
  });

  /// The column names returned by the query.
  final List<String> columns;

  /// The rows returned by the database from the query.
  final List<List<Object?>> rows;

  /// The rows affected by the query.
  final int rowsAffected;

  /// The last inserted row id.
  final int? lastInsertedRowId;
}
