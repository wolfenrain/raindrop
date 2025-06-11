import 'package:raindrop/raindrop.dart';

/// {@template query}
/// Base class for any query.
/// {@endtemplate}
abstract class Query<S extends Schema<S>, V> {
  /// {@macro query}
  const Query();
}
