// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs
import 'package:raindrop/raindrop.dart';

extension SelectGroupBy<S extends Schema<R>, R, V>
    on SelectFromBuilder<S, R, V> {
  /// Set the `GROUP BY` terms, in order:
  ///
  /// ```dart
  /// .groupBy(users.country, users.city)
  /// // GROUP BY "country", "city"
  /// ```
  SelectFromBuilder<S, R, V> groupBy(Selectable<dynamic> g0,
      [Selectable<dynamic>? g1,
      Selectable<dynamic>? g2,
      Selectable<dynamic>? g3,
      Selectable<dynamic>? g4,
      Selectable<dynamic>? g5,
      Selectable<dynamic>? g6,
      Selectable<dynamic>? g7,
      Selectable<dynamic>? g8,
      Selectable<dynamic>? g9,
      Selectable<dynamic>? g10,
      Selectable<dynamic>? g11,
      Selectable<dynamic>? g12,
      Selectable<dynamic>? g13,
      Selectable<dynamic>? g14,
      Selectable<dynamic>? g15,
      Selectable<dynamic>? g16,
      Selectable<dynamic>? g17,
      Selectable<dynamic>? g18,
      Selectable<dynamic>? g19]) {
    final terms = [
      g0,
      g1,
      g2,
      g3,
      g4,
      g5,
      g6,
      g7,
      g8,
      g9,
      g10,
      g11,
      g12,
      g13,
      g14,
      g15,
      g16,
      g17,
      g18,
      g19
    ];
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #groupBy: [...terms.nonNulls]
      }),
    );
  }
}

extension WholeRowGroupBy<S extends Schema<R>, R> on WholeRowFromBuilder<S, R> {
  /// Set the `GROUP BY` terms, in order:
  ///
  /// ```dart
  /// .groupBy(users.country, users.city)
  /// // GROUP BY "country", "city"
  /// ```
  WholeRowFromBuilder<S, R> groupBy(Selectable<dynamic> g0,
      [Selectable<dynamic>? g1,
      Selectable<dynamic>? g2,
      Selectable<dynamic>? g3,
      Selectable<dynamic>? g4,
      Selectable<dynamic>? g5,
      Selectable<dynamic>? g6,
      Selectable<dynamic>? g7,
      Selectable<dynamic>? g8,
      Selectable<dynamic>? g9,
      Selectable<dynamic>? g10,
      Selectable<dynamic>? g11,
      Selectable<dynamic>? g12,
      Selectable<dynamic>? g13,
      Selectable<dynamic>? g14,
      Selectable<dynamic>? g15,
      Selectable<dynamic>? g16,
      Selectable<dynamic>? g17,
      Selectable<dynamic>? g18,
      Selectable<dynamic>? g19]) {
    final terms = [
      g0,
      g1,
      g2,
      g3,
      g4,
      g5,
      g6,
      g7,
      g8,
      g9,
      g10,
      g11,
      g12,
      g13,
      g14,
      g15,
      g16,
      g17,
      g18,
      g19
    ];
    return WholeRowFromBuilder(
      executor,
      config: config.copyWith({
        #groupBy: [...terms.nonNulls]
      }),
    );
  }
}

extension ProjectionGroupBy<S extends Schema<R>, R, V>
    on ProjectionFromBuilder<S, R, V> {
  /// Set the `GROUP BY` terms, in order:
  ///
  /// ```dart
  /// .groupBy(users.country, users.city)
  /// // GROUP BY "country", "city"
  /// ```
  ProjectionFromBuilder<S, R, V> groupBy(Selectable<dynamic> g0,
      [Selectable<dynamic>? g1,
      Selectable<dynamic>? g2,
      Selectable<dynamic>? g3,
      Selectable<dynamic>? g4,
      Selectable<dynamic>? g5,
      Selectable<dynamic>? g6,
      Selectable<dynamic>? g7,
      Selectable<dynamic>? g8,
      Selectable<dynamic>? g9,
      Selectable<dynamic>? g10,
      Selectable<dynamic>? g11,
      Selectable<dynamic>? g12,
      Selectable<dynamic>? g13,
      Selectable<dynamic>? g14,
      Selectable<dynamic>? g15,
      Selectable<dynamic>? g16,
      Selectable<dynamic>? g17,
      Selectable<dynamic>? g18,
      Selectable<dynamic>? g19]) {
    final terms = [
      g0,
      g1,
      g2,
      g3,
      g4,
      g5,
      g6,
      g7,
      g8,
      g9,
      g10,
      g11,
      g12,
      g13,
      g14,
      g15,
      g16,
      g17,
      g18,
      g19
    ];
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #groupBy: [...terms.nonNulls]
      }),
    );
  }
}

extension SingleProjectionGroupBy<S extends Schema<R>, R, V>
    on SingleProjectionFromBuilder<S, R, V> {
  /// Set the `GROUP BY` terms, in order:
  ///
  /// ```dart
  /// .groupBy(users.country, users.city)
  /// // GROUP BY "country", "city"
  /// ```
  SingleProjectionFromBuilder<S, R, V> groupBy(Selectable<dynamic> g0,
      [Selectable<dynamic>? g1,
      Selectable<dynamic>? g2,
      Selectable<dynamic>? g3,
      Selectable<dynamic>? g4,
      Selectable<dynamic>? g5,
      Selectable<dynamic>? g6,
      Selectable<dynamic>? g7,
      Selectable<dynamic>? g8,
      Selectable<dynamic>? g9,
      Selectable<dynamic>? g10,
      Selectable<dynamic>? g11,
      Selectable<dynamic>? g12,
      Selectable<dynamic>? g13,
      Selectable<dynamic>? g14,
      Selectable<dynamic>? g15,
      Selectable<dynamic>? g16,
      Selectable<dynamic>? g17,
      Selectable<dynamic>? g18,
      Selectable<dynamic>? g19]) {
    final terms = [
      g0,
      g1,
      g2,
      g3,
      g4,
      g5,
      g6,
      g7,
      g8,
      g9,
      g10,
      g11,
      g12,
      g13,
      g14,
      g15,
      g16,
      g17,
      g18,
      g19
    ];
    return SingleProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #groupBy: [...terms.nonNulls]
      }),
    );
  }
}
