import 'package:raindrop/raindrop.dart';

export 'boolean.dart';
export 'double.dart';
export 'integer.dart';
export 'text.dart';

extension ColumnBuilderProvider<R> on SchemaBuilder<R> {
  /// Register a plain column, wrapping the created [Column] in the column-type
  /// handle produced by [typeBuilder].
  ///
  /// [T] is the column-type handle ([IntColumn] vs [IntColumn?]); [W] is the
  /// field value type ([int] vs [int?]). [Column.isNullable] is `null is W`.
  T column<T extends ColumnType<V?>, V extends Object, W extends Object?>(
    T Function(Column<dynamic, V>) typeBuilder,
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return _column<R, T, V, W>(
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
  T custom<T extends ColumnType<I?>, I extends Object, O extends Object,
      W extends Object?>(
    T Function(Column<dynamic, I>) typeBuilder,
    String name,
    Field<R, W> field, {
    required ColumnTransformer<I, O> transformer,
    String? sqlType,
    String? defaultValue,
  }) {
    return _column<R, T, I, W>(
      this,
      typeBuilder,
      name,
      field,
      transformer: transformer,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }
}

T _column<R, T extends ColumnType<V?>, V extends Object, W extends Object?>(
  SchemaBuilder<R> $,
  T Function(Column<dynamic, V>) typeBuilder,
  String name,
  Field<R, W> field, {
  ColumnTransformer<V, Object?>? transformer,
  String? sqlType,
  String? defaultValue,
}) {
  final column = $.table.addColumn<V>(
    name,
    field as Field<R, V>,
    isNullable: null is W,
    transformer: transformer,
    sqlType: sqlType,
    defaultValue: defaultValue,
  );

  return typeBuilder(column);
}

abstract class ColumnTransformer<I, O> {
  const ColumnTransformer();

  O encode(I input);

  I decode(O input);
}

typedef ColumnOf<V extends Object?> = ColumnType<V>?;

extension type ColumnType<V extends Object?>(Column<dynamic, V> _)
    implements Column<dynamic, V> {}

extension ColumnOperators<V extends Object?> on ColumnOf<V> {
  /// Make an alias of the column.
  ColumnAlias<dynamic, V> as(String alias) => this!.as(alias);

  /// Row value for column is in the list of [values].
  SQL inList(List<V> values) => SQL([this, const RawSQL('IN'), values]);

  /// Returns the count of what is being selected.
  Count<V> count() => Count<V>(this);

  /// Row value for column is null.
  SQL isNull() => SQL([this, const RawSQL('IS NULL')]);
}

extension PrimaryColumn<T extends ColumnType<V>, V extends Object?> on T? {
  /// Marks this column as the primary key (no auto-increment).
  T? primaryKey() {
    if (this case final column?) {
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
    if (this case final column?) {
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

/// Extension to add foreign key references to columns.
extension ReferencesColumn<T extends ColumnType<V>, V extends Object?> on T? {
  /// Adds a foreign key reference to another column.
  T references(
    ColumnOf Function() columnGetter, {
    ReferentialAction? onDelete,
    ReferentialAction? onUpdate,
  }) {
    if (this case final column?) {
      column.foreignKeyReference = ForeignKeyReference(
        referencedColumnGetter: () => columnGetter()!,
        onDelete: onDelete,
        onUpdate: onUpdate,
      );
    }
    return this as T;
  }
}
