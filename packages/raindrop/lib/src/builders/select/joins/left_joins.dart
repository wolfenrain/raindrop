// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tools/generate_the_magic.dart` to regenerate.
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWithLeftJoin0<S extends Schema<R>, R> on SelectFromBuilder<S, R, R> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final s = config.get(#selecting) as Table<S, R>;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R, OR)>([s, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin1<S extends Schema<R>, R, R0, R1> on SelectFromBuilder<S, R, (R0, R1)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin2<S extends Schema<R>, R, R0, R1, R2> on SelectFromBuilder<S, R, (R0, R1, R2)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin3<S extends Schema<R>, R, R0, R1, R2, R3> on SelectFromBuilder<S, R, (R0, R1, R2, R3)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin4<S extends Schema<R>, R, R0, R1, R2, R3, R4> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin5<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin6<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin7<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin8<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin9<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin10<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin11<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin12<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin13<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin14<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin15<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin16<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin17<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin18<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin19<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, OR?)> leftJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}
