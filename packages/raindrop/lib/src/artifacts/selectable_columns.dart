// GENERATED CODE — DO NOT EDIT BY HAND.
// Run `dart run tools/generate_the_magic.dart` to regenerate.
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

/// Extension that provides insert, select, update and delete methods.
///
/// This file is fully generated to allow for resolution logic of types.
extension ISUDRaindropExecutor on RaindropExecutor<RaindropDelegate> {
  /// Create an insert builder for inserting entities [into] the database.
  InsertValuesBuilder<Schema<R>, R, void> insert<R>({required Schema<R> into}) {
    return delegate.insert<R>(this, Table.get(into)! as Table<dynamic, R>);
  }

  /// Create a select builder that can filter down on columns if needed.
  SelectingBuilder<S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19> select<S0 extends Selectable<Object?>?, S1 extends Selectable<Object?>?, S2 extends Selectable<Object?>?, S3 extends Selectable<Object?>?, S4 extends Selectable<Object?>?, S5 extends Selectable<Object?>?, S6 extends Selectable<Object?>?, S7 extends Selectable<Object?>?, S8 extends Selectable<Object?>?, S9 extends Selectable<Object?>?, S10 extends Selectable<Object?>?, S11 extends Selectable<Object?>?, S12 extends Selectable<Object?>?, S13 extends Selectable<Object?>?, S14 extends Selectable<Object?>?, S15 extends Selectable<Object?>?, S16 extends Selectable<Object?>?, S17 extends Selectable<Object?>?, S18 extends Selectable<Object?>?, S19 extends Selectable<Object?>?>([S0? s0, S1? s1, S2? s2, S3? s3, S4? s4, S5? s5, S6? s6, S7? s7, S8? s8, S9? s9, S10? s10, S11? s11, S12? s12, S13? s13, S14? s14, S15? s15, S16? s16, S17? s17, S18? s18, S19? s19]) {
    return delegate.select(this, _Selecting<S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19>(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19));
  }

  /// Create an update builder that can update a [table].
  UpdateSettingBuilder<Schema<R>, R, void> update<R>(Schema<R> table) {
    return delegate.update<R>(this, Table.get(table)! as Table<dynamic, R>);
  }

  /// Create a delete builder that can delete data [from] the database.
  DeleteAllBuilder<Schema<R>, R, void> delete<R>({required Schema<R> from}) {
    return delegate.delete<R>(this, Table.get(from)! as Table<dynamic, R>);
  }
}

typedef SelectingBuilder<S0 extends Selectable<Object?>?, S1 extends Selectable<Object?>?, S2 extends Selectable<Object?>?, S3 extends Selectable<Object?>?, S4 extends Selectable<Object?>?, S5 extends Selectable<Object?>?, S6 extends Selectable<Object?>?, S7 extends Selectable<Object?>?, S8 extends Selectable<Object?>?, S9 extends Selectable<Object?>?, S10 extends Selectable<Object?>?, S11 extends Selectable<Object?>?, S12 extends Selectable<Object?>?, S13 extends Selectable<Object?>?, S14 extends Selectable<Object?>?, S15 extends Selectable<Object?>?, S16 extends Selectable<Object?>?, S17 extends Selectable<Object?>?, S18 extends Selectable<Object?>?, S19 extends Selectable<Object?>?> = SelectBuilder<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19)?>;

typedef _Unused = Selectable<Object?>?;

class _Selecting<S0 extends Selectable<Object?>?, S1 extends Selectable<Object?>?, S2 extends Selectable<Object?>?, S3 extends Selectable<Object?>?, S4 extends Selectable<Object?>?, S5 extends Selectable<Object?>?, S6 extends Selectable<Object?>?, S7 extends Selectable<Object?>?, S8 extends Selectable<Object?>?, S9 extends Selectable<Object?>?, S10 extends Selectable<Object?>?, S11 extends Selectable<Object?>?, S12 extends Selectable<Object?>?, S13 extends Selectable<Object?>?, S14 extends Selectable<Object?>?, S15 extends Selectable<Object?>?, S16 extends Selectable<Object?>?, S17 extends Selectable<Object?>?, S18 extends Selectable<Object?>?, S19 extends Selectable<Object?>?> implements Selectable<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19)?> {
  const _Selecting(this.s0, this.s1, this.s2, this.s3, this.s4, this.s5, this.s6, this.s7, this.s8, this.s9, this.s10, this.s11, this.s12, this.s13, this.s14, this.s15, this.s16, this.s17, this.s18, this.s19);

  final S0? s0;
  final S1? s1;
  final S2? s2;
  final S3? s3;
  final S4? s4;
  final S5? s5;
  final S6? s6;
  final S7? s7;
  final S8? s8;
  final S9? s9;
  final S10? s10;
  final S11? s11;
  final S12? s12;
  final S13? s13;
  final S14? s14;
  final S15? s15;
  final S16? s16;
  final S17? s17;
  final S18? s18;
  final S19? s19;
}

extension SelectableColumns on SelectBuilder<(_Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder where the whole table gets selected.
  SelectFromBuilder<Schema<R>, R, R> from<R>(Schema<R> from) {
    final table = Table.get(from);
    return SelectFromBuilder(
      executor,
      config: config.copyWith({#selecting: table, #from: table}),
    );
  }
}

extension SelectableColumns0<V0>
    on SelectBuilder<(Selectable<V0>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, V0> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: selecting.s0,
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns1<V0, V1>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1)>([selecting.s0!, selecting.s1!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns2<V0, V1, V2>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2)>([selecting.s0!, selecting.s1!, selecting.s2!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns3<V0, V1, V2, V3>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns4<V0, V1, V2, V3, V4>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns5<V0, V1, V2, V3, V4, V5>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns6<V0, V1, V2, V3, V4, V5, V6>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns7<V0, V1, V2, V3, V4, V5, V6, V7>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns8<V0, V1, V2, V3, V4, V5, V6, V7, V8>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns9<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns10<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns11<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns12<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns13<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns14<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, Selectable<V14>, _Unused, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!, selecting.s14!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns15<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, Selectable<V14>, Selectable<V15>, _Unused, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!, selecting.s14!, selecting.s15!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns16<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, Selectable<V14>, Selectable<V15>, Selectable<V16>, _Unused, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!, selecting.s14!, selecting.s15!, selecting.s16!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns17<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, Selectable<V14>, Selectable<V15>, Selectable<V16>, Selectable<V17>, _Unused, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!, selecting.s14!, selecting.s15!, selecting.s16!, selecting.s17!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns18<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, Selectable<V14>, Selectable<V15>, Selectable<V16>, Selectable<V17>, Selectable<V18>, _Unused)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!, selecting.s14!, selecting.s15!, selecting.s16!, selecting.s17!, selecting.s18!]),
        #from: Table.get(from),
      }),
    );
  }
}
extension SelectableColumns19<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19>
    on SelectBuilder<(Selectable<V0>, Selectable<V1>, Selectable<V2>, Selectable<V3>, Selectable<V4>, Selectable<V5>, Selectable<V6>, Selectable<V7>, Selectable<V8>, Selectable<V9>, Selectable<V10>, Selectable<V11>, Selectable<V12>, Selectable<V13>, Selectable<V14>, Selectable<V15>, Selectable<V16>, Selectable<V17>, Selectable<V18>, Selectable<V19>)?> {
  /// Create a from builder.
  ProjectionFromBuilder<Schema<R>, R, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19)> from<R>(Schema<R> from) {
    final selecting = config[#selecting]! as _Selecting;
    return ProjectionFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19)>([selecting.s0!, selecting.s1!, selecting.s2!, selecting.s3!, selecting.s4!, selecting.s5!, selecting.s6!, selecting.s7!, selecting.s8!, selecting.s9!, selecting.s10!, selecting.s11!, selecting.s12!, selecting.s13!, selecting.s14!, selecting.s15!, selecting.s16!, selecting.s17!, selecting.s18!, selecting.s19!]),
        #from: Table.get(from),
      }),
    );
  }
}
