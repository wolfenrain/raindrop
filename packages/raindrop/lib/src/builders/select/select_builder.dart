import 'package:raindrop/raindrop.dart';

class NoSchema extends Schema<NoSchema> {}

/// {@template select_builder}
/// Select builder for select queries
/// {@endtemplate}
class SelectBuilder<V extends Object?> extends QueryBuilder<NoSchema, V> {
  /// {@macro select_builder}
  SelectBuilder(
    super.executor, {
    required super.config,
  });
}

/// Provide a from method when nothing is selected.
extension NothingSelected on SelectBuilder<Object?> {
  /// Create a from builder where the whole table gets selected.
  SelectFromBuilder<S, S> from<S extends Schema<S>>(S from) {
    final table = Table.getForSchema<S>();
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#selecting: table, #from: table}),
    );
  }
}

/// Provide a from method when something is selected.
extension SomethingSelected<V extends Object> on SelectBuilder<V> {
  /// Create a from builder.
  SelectFromBuilder<S, V> from<S extends Schema<S>>(S from) {
    final table = Table.getForSchema<S>();
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#from: table}),
    );
  }
}
