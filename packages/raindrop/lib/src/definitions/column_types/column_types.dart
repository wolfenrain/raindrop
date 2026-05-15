import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';

export 'double.dart';
export 'integer.dart';
export 'text.dart';

int _synthCounter = 0;

/// Generates a unique seed value of type [V] used to identify a column during
/// schema registration. The seed lives only inside the schema reference and
/// is the map key into [ColumnType._typeToColumn].
V _synthesize<V>(String column) {
  final n = ++_synthCounter;
  if (V == int) return -n as V;
  if (V == String) return '__synth_$n' as V;
  if (V == double) return (-n.toDouble()) as V;
  if (V == bool) return n.isOdd as V;
  if (V == DateTime) return DateTime.fromMicrosecondsSinceEpoch(n) as V;
  if (V == BigInt) return BigInt.from(-n) as V;
  if (V == Uint8List) return Uint8List(0) as V;
  throw StateError(
    'Cannot synthesize a registration seed of type $V for column "$column". '
    'Provide an explicit value via the column builder.',
  );
}

extension ColumnBuilderProvider<R> on SchemaBuilder<R> {
  /// Register a plain column with [typeBuilder] producing the column-type
  /// wrapper.
  V column<T extends ColumnType<V?>, V extends Object>(
    T Function(V) typeBuilder,
    String name,
    Field<R, V> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return _column<R, T, V>(
      this,
      typeBuilder,
      name,
      field,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }

  /// Register a column with a custom [transformer] between the in-memory
  /// type [I] and the SQL storage type [O].
  I custom<I extends Object, O extends Object>(
    ColumnType<I?> Function(I) typeBuilder,
    String name,
    Field<R, I> field, {
    required ColumnTransformer<I, O> transformer,
    String? sqlType,
    String? defaultValue,

    /// Dummy value passed to [typeBuilder] to produce the [ColumnType] handle
    /// used during registration. If omitted, Raindrop picks a value for a
    /// small set of built-in [V] types; other types must pass an explicit seed.
    I? synthetic,
  }) {
    return _column(
      this,
      typeBuilder,
      name,
      field,
      transformer: transformer,
      sqlType: sqlType,
      defaultValue: defaultValue,
      synthetic: synthetic,
    );
  }
}

V _column<R, T extends ColumnType<V?>, V extends Object>(
  SchemaBuilder<R> $,
  T Function(V) typeBuilder,
  String name,
  Field<R, V> field, {
  ColumnTransformer<V, Object?>? transformer,
  String? sqlType,
  String? defaultValue,
  V? synthetic,
}) {
  final column = $.table.addColumn<V>(
    name,
    field,
    isNullable: null is V,
    transformer: transformer,
    sqlType: sqlType,
    defaultValue: defaultValue,
  );

  final seed = synthetic ?? _synthesize<V>(name);
  ColumnType._typeToColumn[typeBuilder(seed)] = column;
  return seed;
}

abstract class ColumnTransformer<I, O> {
  const ColumnTransformer();

  O encode(I input);

  I decode(O input);
}

typedef ColumnOf<V extends Object?> = ColumnType<V>?;

extension type ColumnType<V extends Object?>._(V _) {
  static final Map<ColumnType, Column> _typeToColumn = {};

  /// Look up the registered [Column] for a column-type reference.
  /// Returns `null` if [column] does not correspond to any registered column.
  static Column? lookup(ColumnType? column) => _typeToColumn[column];
}

extension ColumnTypeX<V extends Object?> on ColumnType<V>? {
  // TODO: validate if this works
  /// Returns the nullable version of this column.
  ColumnType<V?> get nullable => this as ColumnType<V>;
}

extension PrimaryColumn<T extends ColumnType<V>, V extends Object?> on T? {
  /// Marks this column as the primary key (no auto-increment).
  T? primaryKey() {
    if (ColumnType.lookup(this) case final Column<dynamic, dynamic> column) {
      column
        ..isPrimaryKey = true
        ..autoIncrement = false;
    }
    return this;
  }
}

extension PrimaryColumnNonNull<T extends ColumnType<V>, V extends Object?>
    on T {
  /// Marks this column as the primary key (no auto-increment).
  T primaryKey() => PrimaryColumn(this).primaryKey()!;
}

extension PrimaryColumnInteger<T extends ColumnType<int>> on T? {
  /// Marks this integer column as the primary key, optionally with
  /// auto-increment.
  T? primaryKey({required bool autoIncrement}) {
    if (ColumnType.lookup(this) case final Column<dynamic, dynamic> column) {
      column
        ..isPrimaryKey = true
        ..autoIncrement = autoIncrement;
    }
    return this;
  }
}

extension PrimaryColumnIntegerNonNull<T extends ColumnType<int>> on T {
  /// Marks this integer column as the primary key, optionally with
  /// auto-increment.
  T primaryKey({required bool autoIncrement}) =>
      PrimaryColumnInteger(this).primaryKey(autoIncrement: autoIncrement)!;
}

extension ColumnOperators<V extends Object?> on ColumnOf<V> {
  /// Make an alias of the column.
  ColumnAlias<dynamic, V> as(String alias) => $.as(alias);

  /// The column reference for this column-type seed.
  Column<dynamic, V> get $ {
    final column = ColumnType._typeToColumn[this];
    if (column == null) {
      throw StateError(
        'Tried to dereference a column-type value that does not correspond '
        'to any registered column. This typically means `.\$` was called '
        'on a row-instance field rather than on a schema reference.',
      );
    }
    return column as Column<dynamic, V>;
  }

  /// Row value for column is in the list of [values].
  SQL inList(List<V> values) => SQL([$, const RawSQL('IN'), values]);

  /// Returns the count of what is being selected.
  ColumnTransform<dynamic, int> count() => $.transform(
        SQL.function('COUNT', [$]),
      );

  /// Row value for column is null.
  SQL isNull() => SQL([$, const RawSQL('IS NULL')]);
}

/// Extension to add foreign key references to columns.
extension ReferencesColumn<T extends ColumnType<V>, V extends Object?> on T? {
  /// Adds a foreign key reference to another column.
  T references(
    ColumnOf Function() columnGetter, {
    ReferentialAction? onDelete,
    ReferentialAction? onUpdate,
  }) {
    if (ColumnType.lookup(this) case final Column<dynamic, dynamic> column) {
      column.foreignKeyReference = ForeignKeyReference(
        referencedColumnGetter: () => columnGetter().$,
        onDelete: onDelete,
        onUpdate: onUpdate,
      );
    }
    return this as T;
  }
}
