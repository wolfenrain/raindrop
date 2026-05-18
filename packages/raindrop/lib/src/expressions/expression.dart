import 'package:raindrop/raindrop.dart';

/// {@template expression}
/// A typed SQL expression that produces a value of type [V].
/// {@endtemplate}
abstract class Expression<V> implements Selectable<V> {
  /// {@macro expression}
  const Expression();

  /// Build the underlying [SQL] for this expression.
  SQL build();
}
