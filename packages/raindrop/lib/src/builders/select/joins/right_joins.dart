// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWithRightJoin<V extends Object?, S extends Schema<S>> on SelectFromBuilder<S, V> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, V> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(Table.get(table)! as Table<O>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin0<S extends Schema<S>> on SelectFromBuilder<S, S> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final s = config.get(#selecting) as Table<S>;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S, O)>([s, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin1<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?> on SelectFromBuilder<S, (S0, S1)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin2<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?> on SelectFromBuilder<S, (S0, S1, S2)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin3<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?> on SelectFromBuilder<S, (S0, S1, S2, S3)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin4<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin5<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin6<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin7<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin8<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin9<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin10<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin11<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin12<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin13<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin14<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin15<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin16<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin17<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, S17?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, S17?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin18<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?, S18 extends Schema<S18>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, S17?, S18?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, S17?, S18?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithRightJoin19<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?, S18 extends Schema<S18>?, S19 extends Schema<S19>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19)> {
  /// Add a right join clause of the builder.
  SelectFromBuilder<S, (S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, S17?, S18?, S19?, O)> rightJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0?, S1?, S2?, S3?, S4?, S5?, S6?, S7?, S8?, S9?, S10?, S11?, S12?, S13?, S14?, S15?, S16?, S17?, S18?, S19?, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          RightJoin<O>(o, on: on),
        ],
      }),
    );
  }
}
