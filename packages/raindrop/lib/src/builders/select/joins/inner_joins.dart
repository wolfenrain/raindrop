// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWithInnerJoin0<S extends Schema<R>, R>
    on SelectFromBuilder<S, R, R> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final s = config.selecting! as Table<S, R>;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R, OR)>([s, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin1<S extends Schema<R>, R, R0, R1>
    on SelectFromBuilder<S, R, (R0, R1)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, OR)>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin2<S extends Schema<R>, R, R0, R1, R2>
    on SelectFromBuilder<S, R, (R0, R1, R2)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, OR)>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin3<S extends Schema<R>, R, R0, R1, R2, R3>
    on SelectFromBuilder<S, R, (R0, R1, R2, R3)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting:
            SelectableResult<(R0, R1, R2, R3, OR)>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin4<S extends Schema<R>, R, R0, R1, R2, R3, R4>
    on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting:
            SelectableResult<(R0, R1, R2, R3, R4, OR)>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin5<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5>
    on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, OR)>(
            [...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin6<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
    R6> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, OR)>(
            [...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin7<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
    R6, R7> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, OR)>(
            [...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin8<
    S extends Schema<R>,
    R,
    R0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, OR)>(
            [...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin9<
    S extends Schema<R>,
    R,
    R0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, OR)>
      join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting:
            SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, OR)>(
                [...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin10<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10>
    on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, OR)>
      join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting:
            SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, OR)>(
                [...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin11<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11>
    on SelectFromBuilder<S, R,
        (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R,
      (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin12<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12>
    on SelectFromBuilder<S, R,
        (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R,
      (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, OR)> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin13<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13>
    on SelectFromBuilder<S, R,
        (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R,
          (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, OR)>
      join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin14<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13, R14>
    on SelectFromBuilder<S, R,
        (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, R,
          (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, OR)>
      join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              R14,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin15<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13, R14, R15>
    on SelectFromBuilder<
        S,
        R,
        (
          R0,
          R1,
          R2,
          R3,
          R4,
          R5,
          R6,
          R7,
          R8,
          R9,
          R10,
          R11,
          R12,
          R13,
          R14,
          R15
        )> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<
      S,
      R,
      (
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7,
        R8,
        R9,
        R10,
        R11,
        R12,
        R13,
        R14,
        R15,
        OR
      )> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              R14,
              R15,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin16<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16>
    on SelectFromBuilder<
        S,
        R,
        (
          R0,
          R1,
          R2,
          R3,
          R4,
          R5,
          R6,
          R7,
          R8,
          R9,
          R10,
          R11,
          R12,
          R13,
          R14,
          R15,
          R16
        )> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<
      S,
      R,
      (
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7,
        R8,
        R9,
        R10,
        R11,
        R12,
        R13,
        R14,
        R15,
        R16,
        OR
      )> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              R14,
              R15,
              R16,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin17<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17>
    on SelectFromBuilder<
        S,
        R,
        (
          R0,
          R1,
          R2,
          R3,
          R4,
          R5,
          R6,
          R7,
          R8,
          R9,
          R10,
          R11,
          R12,
          R13,
          R14,
          R15,
          R16,
          R17
        )> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<
      S,
      R,
      (
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7,
        R8,
        R9,
        R10,
        R11,
        R12,
        R13,
        R14,
        R15,
        R16,
        R17,
        OR
      )> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              R14,
              R15,
              R16,
              R17,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin18<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18>
    on SelectFromBuilder<
        S,
        R,
        (
          R0,
          R1,
          R2,
          R3,
          R4,
          R5,
          R6,
          R7,
          R8,
          R9,
          R10,
          R11,
          R12,
          R13,
          R14,
          R15,
          R16,
          R17,
          R18
        )> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<
      S,
      R,
      (
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7,
        R8,
        R9,
        R10,
        R11,
        R12,
        R13,
        R14,
        R15,
        R16,
        R17,
        R18,
        OR
      )> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              R14,
              R15,
              R16,
              R17,
              R18,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin19<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5,
        R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19>
    on SelectFromBuilder<
        S,
        R,
        (
          R0,
          R1,
          R2,
          R3,
          R4,
          R5,
          R6,
          R7,
          R8,
          R9,
          R10,
          R11,
          R12,
          R13,
          R14,
          R15,
          R16,
          R17,
          R18,
          R19
        )> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<
      S,
      R,
      (
        R0,
        R1,
        R2,
        R3,
        R4,
        R5,
        R6,
        R7,
        R8,
        R9,
        R10,
        R11,
        R12,
        R13,
        R14,
        R15,
        R16,
        R17,
        R18,
        R19,
        OR
      )> join<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.selecting! as SelectableResult;
    final o = table.$;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<
            (
              R0,
              R1,
              R2,
              R3,
              R4,
              R5,
              R6,
              R7,
              R8,
              R9,
              R10,
              R11,
              R12,
              R13,
              R14,
              R15,
              R16,
              R17,
              R18,
              R19,
              OR
            )>([...result.selected, o]),
        #joins: [
          ...config.joins,
          InnerJoin<Schema<OR>, OR>(o, on: on),
        ],
      }),
    );
  }
}
