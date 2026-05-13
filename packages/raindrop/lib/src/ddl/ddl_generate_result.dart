/// Result of running a dialect DDL generator over diff operations.
class DdlGenerateResult {
  /// Creates a DDL generation result with optional [warnings].
  const DdlGenerateResult({
    required this.sql,
    this.warnings = const [],
  });

  /// Generated SQL (possibly empty).
  final String sql;

  /// Non-fatal messages from the generator (e.g. inferred defaults).
  final List<String> warnings;
}
