import 'package:raindrop/raindrop.dart';

/// Phantom type used as the schema slot in [SelectBuilder] before a
/// concrete schema has been selected via `.from`.
class NoSchema {
  const NoSchema._();
}

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
