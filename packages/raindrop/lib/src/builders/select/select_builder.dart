import 'package:raindrop/raindrop.dart';

/// Schema used for when nothing has been selected yet.
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
