// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension SelectWithLeftJoin<V extends Object?, S extends Schema<S>> on SelectFromBuilder<S, V> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, V> leftJoin<O extends Schema<O>>(
    O table, {
    required Filter on,
  }) {
    return SelectFromBuilder(
      executor,
      config: config.copyWith({
        #joins: <Join>[
          ...config.get(#joins) ?? [],
          LeftJoin<O>(Table.get(table)! as Table<O>, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin0<S extends Schema<S>> on SelectFromBuilder<S, S> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin1<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?> on SelectFromBuilder<S, (S0, S1)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin2<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?> on SelectFromBuilder<S, (S0, S1, S2)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin3<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?> on SelectFromBuilder<S, (S0, S1, S2, S3)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin4<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin5<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin6<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin7<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin8<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin9<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin10<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin11<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin12<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin13<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin14<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin15<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin16<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin17<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin18<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?, S18 extends Schema<S18>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}

extension SelectWithLeftJoin19<S extends Schema<S>, S0 extends Schema<S0>?, S1 extends Schema<S1>?, S2 extends Schema<S2>?, S3 extends Schema<S3>?, S4 extends Schema<S4>?, S5 extends Schema<S5>?, S6 extends Schema<S6>?, S7 extends Schema<S7>?, S8 extends Schema<S8>?, S9 extends Schema<S9>?, S10 extends Schema<S10>?, S11 extends Schema<S11>?, S12 extends Schema<S12>?, S13 extends Schema<S13>?, S14 extends Schema<S14>?, S15 extends Schema<S15>?, S16 extends Schema<S16>?, S17 extends Schema<S17>?, S18 extends Schema<S18>?, S19 extends Schema<S19>?> on SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19)> {
  /// Add a left join clause of the builder.
  SelectFromBuilder<S, (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, O?)> leftJoin<O extends Schema<O>>(
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
          LeftJoin<O>(o, on: on),
        ],
      }),
    );
  }
}
