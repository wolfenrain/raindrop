// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWithRightJoin0<S extends Schema<R>, R> on SelectFromBuilder<S, R, R> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R?, OR)> rightJoin<OR>(
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
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin1<S extends Schema<R>, R, R0, R1> on SelectFromBuilder<S, R, (R0, R1)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin2<S extends Schema<R>, R, R0, R1, R2> on SelectFromBuilder<S, R, (R0, R1, R2)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin3<S extends Schema<R>, R, R0, R1, R2, R3> on SelectFromBuilder<S, R, (R0, R1, R2, R3)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin4<S extends Schema<R>, R, R0, R1, R2, R3, R4> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin5<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin6<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin7<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin8<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin9<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin10<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin11<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin12<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin13<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin14<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin15<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin16<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin17<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, R17?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, R17?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin18<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, R17?, R18?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, R17?, R18?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin19<S extends Schema<R>, R, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19> on SelectFromBuilder<S, R, (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, R16, R17, R18, R19)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, R, (R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, R17?, R18?, R19?, OR)> rightJoin<OR>(
    Schema<OR> table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<dynamic, OR>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(R0?, R1?, R2?, R3?, R4?, R5?, R6?, R7?, R8?, R9?, R10?, R11?, R12?, R13?, R14?, R15?, R16?, R17?, R18?, R19?, OR)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<Schema<OR>, OR>(o as Table<Schema<OR>, OR>, on: on),
        ],
      }),
    );
  }
}
