/// {@template migration}
/// A single migration unit containing a tag and SQL content.
/// {@endtemplate}
class Migration {
  /// {@macro migration}
  const Migration(this.tag, this.sql);

  /// The migration identifier, e.g. "0000_initial".
  final String tag;

  /// The full SQL content to execute.
  final String sql;
}
