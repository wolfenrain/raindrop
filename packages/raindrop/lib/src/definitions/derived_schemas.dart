// GENERATED CODE - DO NOT EDIT BY HAND.
// Run `dart run tool/generate_the_magic.dart` to regenerate.
// coverage:ignore-file
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';
import 'package:raindrop/src/builders/derived.dart';
import 'package:raindrop/src/definitions/table.dart';

class Derived1<V0> extends Schema<(V0,)> {
  Derived1(super.$, this.$1);

  final ColumnType<V0> $1;

  @override
  (V0,) fromRow(RowReader read) => (read($1),);
}

extension DerivedProjection1<V0>
    on SingleProjectionFromBuilder<Schema<dynamic>, dynamic, V0> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived1<V0> derived({String? as}) {
    final prepared = prepareDerived<V0>(this);
    return derivedTable<Derived1<V0>, (V0,)>(
      as ?? defaultDerivedName(config),
      ($) => Derived1<V0>(
        $,
        ColumnType(derivedColumn<(V0,), V0>($, prepared, 0, (r) => r.$1)),
      ),
      prepared.query,
    );
  }
}

class Derived2<V0, V1> extends Schema<(V0, V1)> {
  Derived2(super.$, this.$1, this.$2);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;

  @override
  (V0, V1) fromRow(RowReader read) => (read($1), read($2));
}

extension DerivedProjection2<V0, V1>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic, (V0, V1)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived2<V0, V1> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1)>(this);
    return derivedTable<Derived2<V0, V1>, (V0, V1)>(
      as ?? defaultDerivedName(config),
      ($) => Derived2<V0, V1>(
        $,
        ColumnType(derivedColumn<(V0, V1), V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1), V1>($, prepared, 1, (r) => r.$2)),
      ),
      prepared.query,
    );
  }
}

class Derived3<V0, V1, V2> extends Schema<(V0, V1, V2)> {
  Derived3(super.$, this.$1, this.$2, this.$3);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;

  @override
  (V0, V1, V2) fromRow(RowReader read) => (read($1), read($2), read($3));
}

extension DerivedProjection3<V0, V1, V2>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic, (V0, V1, V2)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived3<V0, V1, V2> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2)>(this);
    return derivedTable<Derived3<V0, V1, V2>, (V0, V1, V2)>(
      as ?? defaultDerivedName(config),
      ($) => Derived3<V0, V1, V2>(
        $,
        ColumnType(
            derivedColumn<(V0, V1, V2), V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(
            derivedColumn<(V0, V1, V2), V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(
            derivedColumn<(V0, V1, V2), V2>($, prepared, 2, (r) => r.$3)),
      ),
      prepared.query,
    );
  }
}

class Derived4<V0, V1, V2, V3> extends Schema<(V0, V1, V2, V3)> {
  Derived4(super.$, this.$1, this.$2, this.$3, this.$4);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;

  @override
  (V0, V1, V2, V3) fromRow(RowReader read) =>
      (read($1), read($2), read($3), read($4));
}

extension DerivedProjection4<V0, V1, V2, V3>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic, (V0, V1, V2, V3)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived4<V0, V1, V2, V3> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2, V3)>(this);
    return derivedTable<Derived4<V0, V1, V2, V3>, (V0, V1, V2, V3)>(
      as ?? defaultDerivedName(config),
      ($) => Derived4<V0, V1, V2, V3>(
        $,
        ColumnType(
            derivedColumn<(V0, V1, V2, V3), V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3), V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3), V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3), V3>($, prepared, 3, (r) => r.$4)),
      ),
      prepared.query,
    );
  }
}

class Derived5<V0, V1, V2, V3, V4> extends Schema<(V0, V1, V2, V3, V4)> {
  Derived5(super.$, this.$1, this.$2, this.$3, this.$4, this.$5);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;

  @override
  (V0, V1, V2, V3, V4) fromRow(RowReader read) =>
      (read($1), read($2), read($3), read($4), read($5));
}

extension DerivedProjection5<V0, V1, V2, V3, V4>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic, (V0, V1, V2, V3, V4)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived5<V0, V1, V2, V3, V4> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2, V3, V4)>(this);
    return derivedTable<Derived5<V0, V1, V2, V3, V4>, (V0, V1, V2, V3, V4)>(
      as ?? defaultDerivedName(config),
      ($) => Derived5<V0, V1, V2, V3, V4>(
        $,
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4), V0>(
            $, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4), V1>(
            $, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4), V2>(
            $, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4), V3>(
            $, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4), V4>(
            $, prepared, 4, (r) => r.$5)),
      ),
      prepared.query,
    );
  }
}

class Derived6<V0, V1, V2, V3, V4, V5>
    extends Schema<(V0, V1, V2, V3, V4, V5)> {
  Derived6(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;

  @override
  (V0, V1, V2, V3, V4, V5) fromRow(RowReader read) =>
      (read($1), read($2), read($3), read($4), read($5), read($6));
}

extension DerivedProjection6<V0, V1, V2, V3, V4, V5> on ProjectionFromBuilder<
    Schema<dynamic>, dynamic, (V0, V1, V2, V3, V4, V5)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived6<V0, V1, V2, V3, V4, V5> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2, V3, V4, V5)>(this);
    return derivedTable<Derived6<V0, V1, V2, V3, V4, V5>,
        (V0, V1, V2, V3, V4, V5)>(
      as ?? defaultDerivedName(config),
      ($) => Derived6<V0, V1, V2, V3, V4, V5>(
        $,
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5), V0>(
            $, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5), V1>(
            $, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5), V2>(
            $, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5), V3>(
            $, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5), V4>(
            $, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5), V5>(
            $, prepared, 5, (r) => r.$6)),
      ),
      prepared.query,
    );
  }
}

class Derived7<V0, V1, V2, V3, V4, V5, V6>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6)> {
  Derived7(
      super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6, this.$7);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;

  @override
  (V0, V1, V2, V3, V4, V5, V6) fromRow(RowReader read) =>
      (read($1), read($2), read($3), read($4), read($5), read($6), read($7));
}

extension DerivedProjection7<V0, V1, V2, V3, V4, V5, V6>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived7<V0, V1, V2, V3, V4, V5, V6> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2, V3, V4, V5, V6)>(this);
    return derivedTable<Derived7<V0, V1, V2, V3, V4, V5, V6>,
        (V0, V1, V2, V3, V4, V5, V6)>(
      as ?? defaultDerivedName(config),
      ($) => Derived7<V0, V1, V2, V3, V4, V5, V6>(
        $,
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V0>(
            $, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V1>(
            $, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V2>(
            $, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V3>(
            $, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V4>(
            $, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V5>(
            $, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6), V6>(
            $, prepared, 6, (r) => r.$7)),
      ),
      prepared.query,
    );
  }
}

class Derived8<V0, V1, V2, V3, V4, V5, V6, V7>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6, V7)> {
  Derived8(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6,
      this.$7, this.$8);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8)
      );
}

extension DerivedProjection8<V0, V1, V2, V3, V4, V5, V6, V7>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived8<V0, V1, V2, V3, V4, V5, V6, V7> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2, V3, V4, V5, V6, V7)>(this);
    return derivedTable<Derived8<V0, V1, V2, V3, V4, V5, V6, V7>,
        (V0, V1, V2, V3, V4, V5, V6, V7)>(
      as ?? defaultDerivedName(config),
      ($) => Derived8<V0, V1, V2, V3, V4, V5, V6, V7>(
        $,
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V0>(
            $, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V1>(
            $, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V2>(
            $, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V3>(
            $, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V4>(
            $, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V5>(
            $, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V6>(
            $, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7), V7>(
            $, prepared, 7, (r) => r.$8)),
      ),
      prepared.query,
    );
  }
}

class Derived9<V0, V1, V2, V3, V4, V5, V6, V7, V8>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6, V7, V8)> {
  Derived9(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6,
      this.$7, this.$8, this.$9);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9)
      );
}

extension DerivedProjection9<V0, V1, V2, V3, V4, V5, V6, V7, V8>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived9<V0, V1, V2, V3, V4, V5, V6, V7, V8> derived({String? as}) {
    final prepared = prepareDerived<(V0, V1, V2, V3, V4, V5, V6, V7, V8)>(this);
    return derivedTable<Derived9<V0, V1, V2, V3, V4, V5, V6, V7, V8>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8)>(
      as ?? defaultDerivedName(config),
      ($) => Derived9<V0, V1, V2, V3, V4, V5, V6, V7, V8>(
        $,
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V0>(
            $, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V1>(
            $, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V2>(
            $, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V3>(
            $, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V4>(
            $, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V5>(
            $, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V6>(
            $, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V7>(
            $, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8), V8>(
            $, prepared, 8, (r) => r.$9)),
      ),
      prepared.query,
    );
  }
}

class Derived10<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)> {
  Derived10(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6,
      this.$7, this.$8, this.$9, this.$10);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10)
      );
}

extension DerivedProjection10<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived10<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9> derived({String? as}) {
    final prepared =
        prepareDerived<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)>(this);
    return derivedTable<Derived10<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)>(
      as ?? defaultDerivedName(config),
      ($) => Derived10<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9>(
        $,
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V0>(
            $, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V1>(
            $, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V2>(
            $, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V3>(
            $, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V4>(
            $, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V5>(
            $, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V6>(
            $, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V7>(
            $, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V8>(
            $, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9), V9>(
            $, prepared, 9, (r) => r.$10)),
      ),
      prepared.query,
    );
  }
}

class Derived11<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)> {
  Derived11(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6,
      this.$7, this.$8, this.$9, this.$10, this.$11);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11)
      );
}

extension DerivedProjection11<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived11<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10> derived({String? as}) {
    final prepared =
        prepareDerived<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)>(this);
    return derivedTable<Derived11<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10)>(
      as ?? defaultDerivedName(config),
      ($) => Derived11<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10>(
        $,
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V0>(
                $, prepared, 0, (r) => r.$1)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V1>(
                $, prepared, 1, (r) => r.$2)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V2>(
                $, prepared, 2, (r) => r.$3)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V3>(
                $, prepared, 3, (r) => r.$4)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V4>(
                $, prepared, 4, (r) => r.$5)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V5>(
                $, prepared, 5, (r) => r.$6)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V6>(
                $, prepared, 6, (r) => r.$7)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V7>(
                $, prepared, 7, (r) => r.$8)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V8>(
                $, prepared, 8, (r) => r.$9)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V9>(
                $, prepared, 9, (r) => r.$10)),
        ColumnType(
            derivedColumn<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10), V10>(
                $, prepared, 10, (r) => r.$11)),
      ),
      prepared.query,
    );
  }
}

class Derived12<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)> {
  Derived12(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6,
      this.$7, this.$8, this.$9, this.$10, this.$11, this.$12);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11) fromRow(RowReader read) =>
      (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12)
      );
}

extension DerivedProjection12<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived12<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11> derived(
      {String? as}) {
    final prepared =
        prepareDerived<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)>(
            this);
    return derivedTable<
        Derived12<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)>(
      as ?? defaultDerivedName(config),
      ($) => Derived12<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11>(
        $,
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11),
            V11>($, prepared, 11, (r) => r.$12)),
      ),
      prepared.query,
    );
  }
}

class Derived13<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12>
    extends Schema<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)> {
  Derived13(super.$, this.$1, this.$2, this.$3, this.$4, this.$5, this.$6,
      this.$7, this.$8, this.$9, this.$10, this.$11, this.$12, this.$13);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12) fromRow(
          RowReader read) =>
      (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12),
        read($13)
      );
}

extension DerivedProjection13<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11,
        V12>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived13<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12> derived(
      {String? as}) {
    final prepared =
        prepareDerived<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)>(
            this);
    return derivedTable<
        Derived13<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12)>(
      as ?? defaultDerivedName(config),
      ($) => Derived13<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12>(
        $,
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12),
            V12>($, prepared, 12, (r) => r.$13)),
      ),
      prepared.query,
    );
  }
}

class Derived14<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13>
    extends Schema<
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)> {
  Derived14(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13) fromRow(
          RowReader read) =>
      (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12),
        read($13),
        read($14)
      );
}

extension DerivedProjection14<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11,
        V12, V13>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived14<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13> derived(
      {String? as}) {
    final prepared = prepareDerived<
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)>(this);
    return derivedTable<
        Derived14<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13)>(
      as ?? defaultDerivedName(config),
      ($) =>
          Derived14<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13>(
        $,
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13),
            V13>($, prepared, 13, (r) => r.$14)),
      ),
      prepared.query,
    );
  }
}

class Derived15<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14>
    extends Schema<
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14)> {
  Derived15(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14,
      this.$15);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;
  final ColumnType<V14> $15;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14) fromRow(
          RowReader read) =>
      (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12),
        read($13),
        read($14),
        read($15)
      );
}

extension DerivedProjection15<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11,
        V12, V13, V14>
    on ProjectionFromBuilder<Schema<dynamic>, dynamic,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14)> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived15<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14>
      derived({String? as}) {
    final prepared = prepareDerived<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14
        )>(this);
    return derivedTable<
        Derived15<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13,
            V14>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14)>(
      as ?? defaultDerivedName(config),
      ($) => Derived15<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12,
          V13, V14>(
        $,
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V13>($, prepared, 13, (r) => r.$14)),
        ColumnType(derivedColumn<
            (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14),
            V14>($, prepared, 14, (r) => r.$15)),
      ),
      prepared.query,
    );
  }
}

class Derived16<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
        V15>
    extends Schema<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15
        )> {
  Derived16(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14,
      this.$15,
      this.$16);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;
  final ColumnType<V14> $15;
  final ColumnType<V15> $16;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15)
      fromRow(RowReader read) => (
            read($1),
            read($2),
            read($3),
            read($4),
            read($5),
            read($6),
            read($7),
            read($8),
            read($9),
            read($10),
            read($11),
            read($12),
            read($13),
            read($14),
            read($15),
            read($16)
          );
}

extension DerivedProjection16<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11,
        V12, V13, V14, V15>
    on ProjectionFromBuilder<
        Schema<dynamic>,
        dynamic,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15
        )> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived16<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
      V15> derived({String? as}) {
    final prepared = prepareDerived<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15
        )>(this);
    return derivedTable<
        Derived16<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13,
            V14, V15>,
        (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15)>(
      as ?? defaultDerivedName(config),
      ($) => Derived16<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12,
          V13, V14, V15>(
        $,
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V13>($, prepared, 13, (r) => r.$14)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V14>($, prepared, 14, (r) => r.$15)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15
            ),
            V15>($, prepared, 15, (r) => r.$16)),
      ),
      prepared.query,
    );
  }
}

class Derived17<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
        V15, V16>
    extends Schema<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16
        )> {
  Derived17(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14,
      this.$15,
      this.$16,
      this.$17);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;
  final ColumnType<V14> $15;
  final ColumnType<V15> $16;
  final ColumnType<V16> $17;

  @override
  (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16)
      fromRow(RowReader read) => (
            read($1),
            read($2),
            read($3),
            read($4),
            read($5),
            read($6),
            read($7),
            read($8),
            read($9),
            read($10),
            read($11),
            read($12),
            read($13),
            read($14),
            read($15),
            read($16),
            read($17)
          );
}

extension DerivedProjection17<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11,
        V12, V13, V14, V15, V16>
    on ProjectionFromBuilder<
        Schema<dynamic>,
        dynamic,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16
        )> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived17<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
      V15, V16> derived({String? as}) {
    final prepared = prepareDerived<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16
        )>(this);
    return derivedTable<
        Derived17<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13,
            V14, V15, V16>,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16
        )>(
      as ?? defaultDerivedName(config),
      ($) => Derived17<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12,
          V13, V14, V15, V16>(
        $,
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V13>($, prepared, 13, (r) => r.$14)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V14>($, prepared, 14, (r) => r.$15)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V15>($, prepared, 15, (r) => r.$16)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16
            ),
            V16>($, prepared, 16, (r) => r.$17)),
      ),
      prepared.query,
    );
  }
}

class Derived18<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
        V15, V16, V17>
    extends Schema<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17
        )> {
  Derived18(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14,
      this.$15,
      this.$16,
      this.$17,
      this.$18);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;
  final ColumnType<V14> $15;
  final ColumnType<V15> $16;
  final ColumnType<V16> $17;
  final ColumnType<V17> $18;

  @override
  (
    V0,
    V1,
    V2,
    V3,
    V4,
    V5,
    V6,
    V7,
    V8,
    V9,
    V10,
    V11,
    V12,
    V13,
    V14,
    V15,
    V16,
    V17
  ) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12),
        read($13),
        read($14),
        read($15),
        read($16),
        read($17),
        read($18)
      );
}

extension DerivedProjection18<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11,
        V12, V13, V14, V15, V16, V17>
    on ProjectionFromBuilder<
        Schema<dynamic>,
        dynamic,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17
        )> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived18<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
      V15, V16, V17> derived({String? as}) {
    final prepared = prepareDerived<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17
        )>(this);
    return derivedTable<
        Derived18<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13,
            V14, V15, V16, V17>,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17
        )>(
      as ?? defaultDerivedName(config),
      ($) => Derived18<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12,
          V13, V14, V15, V16, V17>(
        $,
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V13>($, prepared, 13, (r) => r.$14)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V14>($, prepared, 14, (r) => r.$15)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V15>($, prepared, 15, (r) => r.$16)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V16>($, prepared, 16, (r) => r.$17)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17
            ),
            V17>($, prepared, 17, (r) => r.$18)),
      ),
      prepared.query,
    );
  }
}

class Derived19<V0, V1, V2, V3, V4,
        V5, V6, V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18>
    extends Schema<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18
        )> {
  Derived19(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14,
      this.$15,
      this.$16,
      this.$17,
      this.$18,
      this.$19);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;
  final ColumnType<V14> $15;
  final ColumnType<V15> $16;
  final ColumnType<V16> $17;
  final ColumnType<V17> $18;
  final ColumnType<V18> $19;

  @override
  (
    V0,
    V1,
    V2,
    V3,
    V4,
    V5,
    V6,
    V7,
    V8,
    V9,
    V10,
    V11,
    V12,
    V13,
    V14,
    V15,
    V16,
    V17,
    V18
  ) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12),
        read($13),
        read($14),
        read($15),
        read($16),
        read($17),
        read($18),
        read($19)
      );
}

extension DerivedProjection19<V0, V1, V2, V3, V4, V5, V6, V7,
        V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18>
    on ProjectionFromBuilder<
        Schema<dynamic>,
        dynamic,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18
        )> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived19<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
      V15, V16, V17, V18> derived({String? as}) {
    final prepared = prepareDerived<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18
        )>(this);
    return derivedTable<
        Derived19<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13,
            V14, V15, V16, V17, V18>,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18
        )>(
      as ?? defaultDerivedName(config),
      ($) => Derived19<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12,
          V13, V14, V15, V16, V17, V18>(
        $,
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V13>($, prepared, 13, (r) => r.$14)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V14>($, prepared, 14, (r) => r.$15)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V15>($, prepared, 15, (r) => r.$16)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V16>($, prepared, 16, (r) => r.$17)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V17>($, prepared, 17, (r) => r.$18)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18
            ),
            V18>($, prepared, 18, (r) => r.$19)),
      ),
      prepared.query,
    );
  }
}

class Derived20<V0, V1, V2, V3, V4, V5, V6,
        V7, V8, V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19>
    extends Schema<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18,
          V19
        )> {
  Derived20(
      super.$,
      this.$1,
      this.$2,
      this.$3,
      this.$4,
      this.$5,
      this.$6,
      this.$7,
      this.$8,
      this.$9,
      this.$10,
      this.$11,
      this.$12,
      this.$13,
      this.$14,
      this.$15,
      this.$16,
      this.$17,
      this.$18,
      this.$19,
      this.$20);

  final ColumnType<V0> $1;
  final ColumnType<V1> $2;
  final ColumnType<V2> $3;
  final ColumnType<V3> $4;
  final ColumnType<V4> $5;
  final ColumnType<V5> $6;
  final ColumnType<V6> $7;
  final ColumnType<V7> $8;
  final ColumnType<V8> $9;
  final ColumnType<V9> $10;
  final ColumnType<V10> $11;
  final ColumnType<V11> $12;
  final ColumnType<V12> $13;
  final ColumnType<V13> $14;
  final ColumnType<V14> $15;
  final ColumnType<V15> $16;
  final ColumnType<V16> $17;
  final ColumnType<V17> $18;
  final ColumnType<V18> $19;
  final ColumnType<V19> $20;

  @override
  (
    V0,
    V1,
    V2,
    V3,
    V4,
    V5,
    V6,
    V7,
    V8,
    V9,
    V10,
    V11,
    V12,
    V13,
    V14,
    V15,
    V16,
    V17,
    V18,
    V19
  ) fromRow(RowReader read) => (
        read($1),
        read($2),
        read($3),
        read($4),
        read($5),
        read($6),
        read($7),
        read($8),
        read($9),
        read($10),
        read($11),
        read($12),
        read($13),
        read($14),
        read($15),
        read($16),
        read($17),
        read($18),
        read($19),
        read($20)
      );
}

extension DerivedProjection20<V0, V1, V2, V3, V4, V5, V6, V7, V8,
        V9, V10, V11, V12, V13, V14, V15, V16, V17, V18, V19>
    on ProjectionFromBuilder<
        Schema<dynamic>,
        dynamic,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18,
          V19
        )> {
  /// The rows this projection returns, usable where a table is.
  ///
  /// Pass [as] when a single query holds more than one derived table, so their
  /// names cannot collide.
  Derived20<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13, V14,
      V15, V16, V17, V18, V19> derived({String? as}) {
    final prepared = prepareDerived<
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18,
          V19
        )>(this);
    return derivedTable<
        Derived20<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12, V13,
            V14, V15, V16, V17, V18, V19>,
        (
          V0,
          V1,
          V2,
          V3,
          V4,
          V5,
          V6,
          V7,
          V8,
          V9,
          V10,
          V11,
          V12,
          V13,
          V14,
          V15,
          V16,
          V17,
          V18,
          V19
        )>(
      as ?? defaultDerivedName(config),
      ($) => Derived20<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11, V12,
          V13, V14, V15, V16, V17, V18, V19>(
        $,
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V0>($, prepared, 0, (r) => r.$1)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V1>($, prepared, 1, (r) => r.$2)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V2>($, prepared, 2, (r) => r.$3)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V3>($, prepared, 3, (r) => r.$4)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V4>($, prepared, 4, (r) => r.$5)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V5>($, prepared, 5, (r) => r.$6)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V6>($, prepared, 6, (r) => r.$7)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V7>($, prepared, 7, (r) => r.$8)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V8>($, prepared, 8, (r) => r.$9)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V9>($, prepared, 9, (r) => r.$10)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V10>($, prepared, 10, (r) => r.$11)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V11>($, prepared, 11, (r) => r.$12)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V12>($, prepared, 12, (r) => r.$13)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V13>($, prepared, 13, (r) => r.$14)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V14>($, prepared, 14, (r) => r.$15)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V15>($, prepared, 15, (r) => r.$16)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V16>($, prepared, 16, (r) => r.$17)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V17>($, prepared, 17, (r) => r.$18)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V18>($, prepared, 18, (r) => r.$19)),
        ColumnType(derivedColumn<
            (
              V0,
              V1,
              V2,
              V3,
              V4,
              V5,
              V6,
              V7,
              V8,
              V9,
              V10,
              V11,
              V12,
              V13,
              V14,
              V15,
              V16,
              V17,
              V18,
              V19
            ),
            V19>($, prepared, 19, (r) => r.$20)),
      ),
      prepared.query,
    );
  }
}
