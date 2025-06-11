import 'package:raindrop/raindrop.dart';

/// {@template insert_builder}
/// The base class of any insert builder.
/// {@endtemplate}
abstract class InsertBuilder<S extends Schema<S>, V>
    extends QueryBuilder<S, V> {
  /// {@macro insert_builder}
  InsertBuilder(super.executor, {required super.config});
}
