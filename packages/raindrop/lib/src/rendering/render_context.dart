import 'package:raindrop/dialect.dart';

/// {@template render_context}
/// A helper passed to each [Clause] while it renders SQL.
///
/// A clause uses it to quote identifiers ([escapeName]) and turn values into
/// bind placeholders ([param]).
/// {@endtemplate}
class RenderContext {
  /// {@macro render_context}
  RenderContext(this.dialect);

  /// The dialect this context uses for identifier quoting ([escapeName]) and
  /// bind-placeholder syntax ([param]).
  final SqlDialect dialect;

  /// The bind values gathered in render order, one per [param] call.
  final List<Object?> values = [];

  /// Escapes an identifier (table/column name).
  String escapeName(String name) => dialect.escapeName(name);

  /// Records [value] as the next bind parameter and returns its placeholder
  /// in the dialect's syntax, keeping [values] and the emitted SQL in sync.
  String param(Object? value) {
    final placeholder = dialect.escapeParam(values.length);
    values.add(value);
    return placeholder;
  }
}
