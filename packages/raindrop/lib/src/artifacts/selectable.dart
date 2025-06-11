// ignore_for_file: strict_raw_type

import 'package:raindrop/raindrop.dart';

/// Interface for making a class selectable.
///
/// Used internally.
abstract interface class Selectable<V> {
  /// Read the given selectable into proper data of the type [V].
  static V read<V>(
    Selectable<V> selectable,
    Map<String, dynamic> data,
    AliasRegistry registry,
  ) {
    if (selectable is Table) {
      final tableName = registry.name(selectable);
      final tableData = {
        for (final e
            in data.entries.where((e) => e.key.startsWith('$tableName.')))
          registry.column(e.key).name: e.value,
      };

      final table = selectable as Table;
      return table.create(tableData) as V;
    } else if (selectable is Column) {
      return data[registry.name(selectable)] as V;
    } else if (selectable is SelectableResult) {
      return (selectable as SelectableResult).read(data, registry) as V;
    }

    throw UnsupportedError('$selectable');
  }
}

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
