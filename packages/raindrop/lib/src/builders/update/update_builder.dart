import 'package:raindrop/raindrop.dart';

/// {@template update_builder}
/// Base update builder class.
/// {@endtemplate}
abstract class UpdateBuilder<S extends Schema<R>, R, V>
    extends QueryBuilder<S, V> {
  /// {@macro update_builder}
  UpdateBuilder(super.executor, {required super.config});
}
