// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWithInnerJoin<V extends Object?, S extends Schema<S>> on SelectFromBuilder<S, V> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, V> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(Table.get(table)! as Table<O>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin0<S extends Schema<S>> on SelectFromBuilder<S, S> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S, O)> join<O extends Schema<O>>(
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
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin1<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?> on SelectFromBuilder<S, (S0, S1)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin2<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?> on SelectFromBuilder<S, (S0, S1, S2)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin3<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?> on SelectFromBuilder<S, (S0, S1, S2, S3)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin4<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin5<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin6<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin7<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin8<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin9<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin10<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin11<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin12<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin13<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin14<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin15<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin16<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin17<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin18<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?, S18 extends Schema<S18>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithInnerJoin19<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?, S18 extends Schema<S18>?, S19 extends Schema<S19>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19)> {
  /// Add a inner join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, O)> join<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    final result = config.get(#selecting) as SelectableResult;
    final o = Table.get(table)! as Table<O>;

    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #selecting: SelectableResult<(S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, O)>([...result.selected, o]),
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          InnerJoin<O>(o, on: on),
        ],
      }),
    );
  }
}
