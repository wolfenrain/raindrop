import 'package:raindrop/raindrop.dart';

/// {@template insert_values_builder}
/// The insert builder that takes a list of values.
/// {@endtemplate}
class InsertValuesBuilder<S extends Schema<R>, R, V> extends InsertBuilder<S, R, V> {
  /// {@macro insert_values_builder}
  InsertValuesBuilder(super.executor, {required super.config});

  /// Add the [values] to the builder.
  InsertWithValuesBuilder<S, R, V> values(List<R> values) {
    return InsertWithValuesBuilder(
      executor,
      config: config.copyWith({
        #values: [...values],
      }),
    );
  }
}

/// {@template insert_with_values_builder}
/// An insert builder that has values to insert.
/// {@endtemplate}
class InsertWithValuesBuilder<S extends Schema<R>, R, V>
    extends InsertBuilder<S, R, V> with ToQuery<S, V> {
  /// {@macro insert_with_values_builder}
  InsertWithValuesBuilder(super.executor, {required super.config});

  @override
  Query<S, V> toQuery() {
    return Insert(
      into: config.get(#into) as Table<S, R>,
      values: config.get(#values)!,
    );
  }
}
