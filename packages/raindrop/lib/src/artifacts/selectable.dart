// ignore_for_file: strict_raw_type

/// Interface for making a class selectable.
///
/// Used internally.
abstract interface class Selectable<V> {}

/// {@template selectable_result}
/// List of selectable results
///
/// Used internally.
/// {@endtemplate}
class SelectableResult<V> implements Selectable<V> {
  /// {@macro selectable_result}
  const SelectableResult(this.selected);

  /// The selected items.
  final List<Selectable> selected;
}
