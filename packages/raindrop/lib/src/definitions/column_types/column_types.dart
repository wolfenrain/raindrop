import 'package:meta/meta.dart';
import 'package:raindrop/raindrop.dart';

export 'boolean.dart';
export 'integer.dart';
export 'text.dart';

extension ColumnBuilderProvider<R> on SchemaBuilder<R> {
  /// Register a plain column.
  ///
  /// [V] is the SQL storage type (`int`) while [W] is the field value type
  /// (`int` vs `int?`), inferred from the field accessor's return type.
  ColumnType<W> column<V extends Object, W extends V?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    ColumnOr<V>? defaultValue,
  }) {
    return _column<R, V, W>(
      this,
      name,
      field,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }

  /// Register a column with a custom [transformer] between the in-memory
  /// type [I] and the SQL storage type [O]. [W] is the field value type, so
  /// nullability follows the accessor (see [column]).
  ColumnType<W> custom<I extends Object, O extends Object, W extends I?>(
    String name,
    Field<R, W> field, {
    required ColumnTransformer<I, O> transformer,
    String? sqlType,
    ColumnOr<I>? defaultValue,
  }) {
    return _column<R, I, W>(
      this,
      name,
      field,
      transformer: transformer,
      sqlType: sqlType,
      defaultValue: defaultValue,
    );
  }
}

ColumnType<W> _column<R, V extends Object, W extends V?>(
  SchemaBuilder<R> $,
  String name,
  Field<R, W> field, {
  ColumnTransformer<V, Object?>? transformer,
  String? sqlType,
  ColumnOr<V>? defaultValue,
}) {
  final column = $.table.addColumn<V>(
    name,
    field,
    isNullable: null is W,
    transformer: transformer,
    sqlType: sqlType,
    defaultValue: defaultValue,
  );

  return ColumnType<W>(column as Column<dynamic, W>);
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

  /// Row value for column equals [value].
  SQL equals(ColumnOr<V> value) => SQL([this, Op.equals, operand(value)]);

  /// Row value for column does not equal [value]. Binds like [equals].
  SQL notEquals(ColumnOr<V> value) => SQL([this, Op.notEquals, operand(value)]);

  /// Row value for column is in the list of [values].
  ///
  /// An empty [values] list can never match, so it emits an always-false
  /// predicate rather than the invalid `IN ()`.
  SQL inList(List<ColumnOr<V>> values) => switch (values) {
        final list when list.isEmpty => SQL([const RawSQL('1 = 0')]),
        final values => SQL([
            this,
            const RawSQL('IN'),
            [...values.map(operand)],
          ]),
      };

  /// Row value for column is in the rows [query] returns.
  SQL inQuery(ToQuery<dynamic, V> query) =>
      SQL([this, const RawSQL('IN'), subquery(query)]);

  /// Prepares a predicate operand.
  ///
  /// A column or an expression is already SQL and passes straight through.
  /// Only a literal is encoded, through the column's transformer (a no-op when
  /// there is none).
  @protected
  Object? operand(ColumnOr<V> value) => operandFor(this!, value);

  /// Returns the count of what is being selected.
  Count<V> count() => Count<V>(this);

  /// Row value for column is null.
  SQL isNull() => SQL([this, const RawSQL('IS NULL')]);

  /// Row value for column is not null.
  SQL isNotNull() => SQL([this, const RawSQL('IS NOT NULL')]);
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

extension PrimaryColumnInteger<T extends ColumnType<int?>> on T {
  /// Marks this integer column as the primary key, optionally with
  /// auto-increment.
  T primaryKey({required bool autoIncrement}) {
    if (this case final column) {
      column
        ..isPrimaryKey = true
        ..autoIncrement = autoIncrement;
    }
    return this;
  }
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
