import 'package:raindrop/raindrop.dart';

/// Provide a `NOT` inversion to an known [filter].
Not not(Filter filter) => Not._(filter);

/// {@template not}
/// Inverts a filter.
/// {@endtemplate}
class Not extends Filter {
  /// {@macro not}
  const Not._(this.invert);

  /// The filter to invert.
  final Filter invert;
}
