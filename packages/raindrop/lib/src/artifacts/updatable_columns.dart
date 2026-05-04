// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

extension UpdatableColumnsOn<S extends Schema<RR>, RR, R> on UpdateSettingBuilder<S, RR, R> {
  /// Set columns to update.
  UpdateSetWhereBuilder<S, RR, V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19, R> set<V0 extends dynamic, V1 extends dynamic, V2 extends dynamic, V3 extends dynamic, V4 extends dynamic, V5 extends dynamic, V6 extends dynamic, V7 extends dynamic, V8 extends dynamic, V9 extends dynamic, V10 extends dynamic, V11 extends dynamic, V12 extends dynamic, V13 extends dynamic, V14 extends dynamic, V15 extends dynamic, V16 extends dynamic, V17 extends dynamic, V18 extends dynamic, V19 extends dynamic>(Updateable<V0> u0, [Updateable<V1>? u1, Updateable<V2>? u2, Updateable<V3>? u3, Updateable<V4>? u4, Updateable<V5>? u5, Updateable<V6>? u6, Updateable<V7>? u7, Updateable<V8>? u8, Updateable<V9>? u9, Updateable<V10>? u10, Updateable<V11>? u11, Updateable<V12>? u12, Updateable<V13>? u13, Updateable<V14>? u14, Updateable<V15>? u15, Updateable<V16>? u16, Updateable<V17>? u17, Updateable<V18>? u18, Updateable<V19>? u19]) {
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: _Set(u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13, u14, u15, u16, u17, u18, u19)}),
    );
  }

  /// Set columns from a list or iterable (e.g. built dynamically, or more than
  /// [set]'s positional limit). Must be non-empty.
  ///
  /// ```dart
  /// db.update(users).setAll([users.name.to('new'), users.age.to(25)]);
  /// ```
  UpdateWhereBuilder<S, RR, List<Object?>?, R> setAll(
      Iterable<Updateable<dynamic>> updates) {
    final list = List<Updateable>.from(updates);
    if (list.isEmpty) {
      throw ArgumentError.value(updates, 'updates', 'must not be empty');
    }
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: UpdateableResult<List<Object?>>(list)}),
    );
  }
}

typedef UpdateSetWhereBuilder<S extends Schema<RR>, RR, V0 extends dynamic, V1 extends dynamic, V2 extends dynamic, V3 extends dynamic, V4 extends dynamic, V5 extends dynamic, V6 extends dynamic, V7 extends dynamic, V8 extends dynamic, V9 extends dynamic, V10 extends dynamic, V11 extends dynamic, V12 extends dynamic, V13 extends dynamic, V14 extends dynamic, V15 extends dynamic, V16 extends dynamic, V17 extends dynamic, V18 extends dynamic, V19 extends dynamic, R> = UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, Updateable<V15>, Updateable<V16>, Updateable<V17>, Updateable<V18>, Updateable<V19>)?, R>;

typedef _Unused = Updateable<dynamic>;

class _Set<U0 extends Updateable<Object?>?, U1 extends Updateable<Object?>?, U2 extends Updateable<Object?>?, U3 extends Updateable<Object?>?, U4 extends Updateable<Object?>?, U5 extends Updateable<Object?>?, U6 extends Updateable<Object?>?, U7 extends Updateable<Object?>?, U8 extends Updateable<Object?>?, U9 extends Updateable<Object?>?, U10 extends Updateable<Object?>?, U11 extends Updateable<Object?>?, U12 extends Updateable<Object?>?, U13 extends Updateable<Object?>?, U14 extends Updateable<Object?>?, U15 extends Updateable<Object?>?, U16 extends Updateable<Object?>?, U17 extends Updateable<Object?>?, U18 extends Updateable<Object?>?, U19 extends Updateable<Object?>?> implements Updateable<(U0, U1, U2, U3, U4, U5, U6, U7, U8, U9, U10, U11, U12, U13, U14, U15, U16, U17, U18, U19)> {
  const _Set(this.u0, this.u1, this.u2, this.u3, this.u4, this.u5, this.u6, this.u7, this.u8, this.u9, this.u10, this.u11, this.u12, this.u13, this.u14, this.u15, this.u16, this.u17, this.u18, this.u19);

  final U0? u0;
  final U1? u1;
  final U2? u2;
  final U3? u3;
  final U4? u4;
  final U5? u5;
  final U6? u6;
  final U7? u7;
  final U8? u8;
  final U9? u9;
  final U10? u10;
  final U11? u11;
  final U12? u12;
  final U13? u13;
  final U14? u14;
  final U15? u15;
  final U16? u16;
  final U17? u17;
  final U18? u18;
  final U19? u19;
}

extension UpdatableSetAllWhere<S extends Schema<RR>, RR, R>
    on UpdateWhereBuilder<S, RR, List<Object?>?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, List<Object?>, R> where(Filter where) {
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#where: where}),
    );
  }
}

extension UpdatableColumns0<S extends Schema<RR>, RR, R, V0 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, V0, R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: set.u0,
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns1<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1)>([set.u0!, set.u1!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns2<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2)>([set.u0!, set.u1!, set.u2!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns3<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3)>([set.u0!, set.u1!, set.u2!, set.u3!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns4<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns5<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns6<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns7<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns8<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns9<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns10<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns11<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns12<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns13<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, _Unused, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns14<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object, V14 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, _Unused, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!, set.u14!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns15<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object, V14 extends Object, V15 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, Updateable<V15>, _Unused, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!, set.u14!, set.u15!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns16<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object, V14 extends Object, V15 extends Object, V16 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, Updateable<V15>, Updateable<V16>, _Unused, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!, set.u14!, set.u15!, set.u16!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns17<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object, V14 extends Object, V15 extends Object, V16 extends Object, V17 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, Updateable<V15>, Updateable<V16>, Updateable<V17>, _Unused, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!, set.u14!, set.u15!, set.u16!, set.u17!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns18<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object, V14 extends Object, V15 extends Object, V16 extends Object, V17 extends Object, V18 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, Updateable<V15>, Updateable<V16>, Updateable<V17>, Updateable<V18>, _Unused)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!, set.u14!, set.u15!, set.u16!, set.u17!, set.u18!]),
        #where: where,
      }),
    );
  }
}

extension UpdatableColumns19<S extends Schema<RR>, RR, R, V0 extends Object, V1 extends Object, V2 extends Object, V3 extends Object, V4 extends Object, V5 extends Object, V6 extends Object, V7 extends Object, V8 extends Object, V9 extends Object, V10 extends Object, V11 extends Object, V12 extends Object, V13 extends Object, V14 extends Object, V15 extends Object, V16 extends Object, V17 extends Object, V18 extends Object, V19 extends Object> on UpdateWhereBuilder<S, RR, (Updateable<V0>, Updateable<V1>, Updateable<V2>, Updateable<V3>, Updateable<V4>, Updateable<V5>, Updateable<V6>, Updateable<V7>, Updateable<V8>, Updateable<V9>, Updateable<V10>, Updateable<V11>, Updateable<V12>, Updateable<V13>, Updateable<V14>, Updateable<V15>, Updateable<V16>, Updateable<V17>, Updateable<V18>, Updateable<V19>)?, R> {
  /// Filter the update query.
  UpdateWhereBuilder<S, RR, (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19), R> where(Filter where) {
    final set = config[#set]! as _Set;
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({
        #set: UpdateableResult<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19)>([set.u0!, set.u1!, set.u2!, set.u3!, set.u4!, set.u5!, set.u6!, set.u7!, set.u8!, set.u9!, set.u10!, set.u11!, set.u12!, set.u13!, set.u14!, set.u15!, set.u16!, set.u17!, set.u18!, set.u19!]),
        #where: where,
      }),
    );
  }
}

