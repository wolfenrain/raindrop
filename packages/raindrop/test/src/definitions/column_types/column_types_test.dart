import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

void main() {
  late final _UserSchema _userSchema;
  late final _ChildSchema _childSchema;
  late final _PersonReadSchema _personReadSchema;
  late final _PersonPkSchema _personPkSchema;

  setUpAll(() {
    _userSchema = table('fk_users', _UserSchema.new);
    _childSchema = table<_ChildSchema, _ChildRow>(
      'fk_children',
      ($) => _ChildSchema($, _userSchema),
    );
    _personReadSchema = table('_people_read', _PersonReadSchema.new);
    _personPkSchema = table('people_pk', _PersonPkSchema.new);
  });

  group('Table.create', () {
    test('reads scalar fields', () {
      final row = _personReadSchema.$.create({
        'id': 99,
        'name': 'ada',
        'active': 1,
        'score': 42,
      });
      expect(row.id, 99);
      expect(row.name, 'ada');
      expect(row.active, isTrue);
      expect(row.score, 42);
    });

    test('reads null for absent nullable scalar', () {
      final row = _personReadSchema.$.create({
        'id': 9101,
        'name': 'b',
        'active': 0,
      });
      expect(row.score, isNull);
    });

    test('decodes booleans from ints', () {
      final row = _personReadSchema.$.create({
        'id': 9102,
        'name': 'c',
        'active': 0,
      });
      expect(row.active, isFalse);
    });
  });

  group('Column.isNullable', () {
    test('is false for required fields, true when wrapper type is nullable',
        () {
      expect(_childSchema.$['owner_key'].isNullable, isFalse);
      expect(_childSchema.$['label'].isNullable, isFalse);
      expect(_childSchema.$['flag'].isNullable, isFalse);
      expect(_childSchema.$['value'].isNullable, isFalse);
      expect(_personReadSchema.$['id'].isNullable, isFalse);
      expect(_personReadSchema.$['name'].isNullable, isFalse);
      expect(_personReadSchema.$['active'].isNullable, isFalse);
      expect(_childSchema.$['orphan_score'].isNullable, isTrue);
      expect(_childSchema.$['desc'].isNullable, isTrue);
      expect(_childSchema.$['muted'].isNullable, isTrue);
      expect(_personReadSchema.$['score'].isNullable, isTrue);
    });
  });

  group('ColumnOperators & IntOperators', () {
    test('nullable casts ColumnType<int?> via extension', () {
      expect(_childSchema.orphanScore?.nullable, isA<ColumnType<int?>>());
    });

    test('equals, comparisons, inList, count, isNull', () {
      final u = _userSchema;
      expect(u.uid.equals(3).toString(), contains('3'));
      expect(u.uid.greaterThan(1), isA<SQL>());
      expect(u.uid.greaterThanOrEqual(2), isA<SQL>());
      expect(u.uid.lessThan(9), isA<SQL>());
      expect(u.uid.lessThanOrEqual(4), isA<SQL>());
      expect(u.uid.inList([10, 20]).toString(), contains('IN'));
      expect(u.uid.count().build().toString(), contains('COUNT'));
      expect(
        _childSchema.orphanScore?.isNull().toString(),
        contains('IS NULL'),
      );
    });
  });

  group('StringOperators', () {
    test('like and equals', () {
      expect(
        _childSchema.label.like('%x%').toString(),
        contains('LIKE'),
      );
      expect(_childSchema.label.equals('hi').toString(), contains('hi'));
    });
  });

  group('BoolOperators', () {
    test('isTrue / isFalse use 1 and 0', () {
      expect(_childSchema.flag.isTrue().toString(), contains('1'));
      expect(_childSchema.flag.isFalse().toString(), contains('0'));
    });
  });

  group('references', () {
    test('sets foreign key metadata on column', () {
      final fk = _childSchema.$['owner_key'].foreignKeyReference!;
      expect(fk.referencedColumnName, 'uid');
      expect(fk.referencedTable, _userSchema.$.name);
      expect(fk.onDelete, ReferentialAction.cascade);
      expect(fk.onUpdate, ReferentialAction.restrict);
    });
  });

  group('primary key', () {
    test('integer primary key can enable autoIncrement', () {
      final col = _personPkSchema.$.columns.firstWhere((c) => c.name == 'id');
      expect(col.isPrimaryKey, isTrue);
      expect(col.autoIncrement, isTrue);
    });

    test('non-nullable int primary disables autoIncrement by default', () {
      final col = _userSchema.$['uid'];
      expect(col.isPrimaryKey, isTrue);
      expect(col.autoIncrement, isFalse);
    });
  });
}

/// Minimal column defs (same pattern as raindrop_sqlite) — exercises core
/// `column` / `custom` in column_types.dart without a package dev_dependency.
///
/// `_column` sets [Column.isNullable] from `null is W` where [W] matches the
/// [Field] type's nullability (e.g. [int] vs [int?]).

extension type _IntColumn(Column<dynamic, int> _) implements ColumnType<int> {}

extension type _TextColumn(Column<dynamic, String> _)
    implements ColumnType<String> {}

extension type _BoolColumn(Column<dynamic, bool> _)
    implements ColumnType<bool> {}

extension _TestInt<R> on SchemaBuilder<R> {
  T integer<T extends _IntColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return column<_IntColumn, int, W>(
      _IntColumn.new,
      name,
      field,
      sqlType: sqlType ?? 'INTEGER',
      defaultValue: defaultValue,
    ) as T;
  }
}

extension _TestText<R> on SchemaBuilder<R> {
  T text<T extends _TextColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return column<_TextColumn, String, W>(
      _TextColumn.new,
      name,
      field,
      sqlType: sqlType ?? 'TEXT',
      defaultValue: defaultValue,
    ) as T;
  }
}

class _BoolTf extends ColumnTransformer<bool, int> {
  const _BoolTf();

  @override
  int encode(bool input) => input ? 1 : 0;

  @override
  bool decode(int input) => input == 1;
}

extension _TestBool<R> on SchemaBuilder<R> {
  T boolean<T extends _BoolColumn?, W extends Object?>(
    String name,
    Field<R, W> field, {
    String? sqlType,
    String? defaultValue,
  }) {
    return custom<_BoolColumn, bool, int, W>(
      _BoolColumn.new,
      name,
      field,
      transformer: const _BoolTf(),
      sqlType: sqlType ?? 'INTEGER',
      defaultValue: defaultValue,
    ) as T;
  }
}

final class _PersonReadRow {
  const _PersonReadRow({
    required this.id,
    required this.name,
    required this.active,
    this.score,
  });

  final int id;
  final String name;
  final bool active;
  final int? score;
}

final class _PersonReadSchema extends Schema<_PersonReadRow> {
  _PersonReadSchema(super.$)
      : id = $.integer<_IntColumn, int>('id', (s) => s.id).primaryKey(
            autoIncrement: true,
          ),
        name = $.text('name', (s) => s.name),
        active = $.boolean('active', (s) => s.active),
        score = $.integer('score', (s) => s.score);

  final _IntColumn id;
  final _TextColumn name;
  final _BoolColumn active;
  final _IntColumn? score;

  @override
  _PersonReadRow fromRow(RowReader read) => _PersonReadRow(
        id: read(id)!,
        name: read(name)!,
        active: read(active)!,
        score: read(score),
      );
}

final class _PersonPkRow {
  const _PersonPkRow({
    required this.id,
    required this.name,
    required this.active,
    this.score,
  });

  final int id;
  final String name;
  final bool active;
  final int? score;
}

final class _PersonPkSchema extends Schema<_PersonPkRow> {
  _PersonPkSchema(super.$)
      : id = $.integer<_IntColumn, int>('id', (s) => s.id).primaryKey(
            autoIncrement: true,
          ),
        name = $.text('name', (s) => s.name),
        active = $.boolean('active', (s) => s.active),
        score = $.integer('score', (s) => s.score);

  final _IntColumn id;
  final _TextColumn name;
  final _BoolColumn active;
  final _IntColumn? score;

  @override
  _PersonPkRow fromRow(RowReader read) => _PersonPkRow(
        id: read(id)!,
        name: read(name)!,
        active: read(active)!,
        score: read(score),
      );
}

final class _UserRow {
  const _UserRow({required this.uid});

  final int uid;
}

final class _UserSchema extends Schema<_UserRow> {
  _UserSchema(super.$)
      : uid = $.integer<_IntColumn, int>('uid', (s) => s.uid).primaryKey(
            autoIncrement: false,
          );

  final _IntColumn uid;

  @override
  _UserRow fromRow(RowReader read) => _UserRow(uid: read(uid)!);
}

final class _ChildRow {
  const _ChildRow({
    required this.ownerKey,
    this.orphanScore,
    required this.flag,
    required this.label,
    required this.value,
    this.desc,
    this.muted,
  });

  final int ownerKey;
  final int? orphanScore;
  final bool flag;
  final String label;
  final int value;
  final String? desc;
  final bool? muted;
}

final class _ChildSchema extends Schema<_ChildRow> {
  _ChildSchema(super.$, _UserSchema userSchema)
      : ownerKey = $
            .integer<_IntColumn, int>('owner_key', (s) => s.ownerKey)
            .references(
              () => userSchema.uid,
              onDelete: ReferentialAction.cascade,
              onUpdate: ReferentialAction.restrict,
            ),
        orphanScore = $.integer('orphan_score', (s) => s.orphanScore),
        flag = $.boolean('flag', (s) => s.flag),
        label = $.text('label', (s) => s.label),
        value = $.integer<_IntColumn, int>('value', (s) => s.value),
        desc = $.text('desc', (s) => s.desc),
        muted = $.boolean('muted', (s) => s.muted);

  final _IntColumn ownerKey;
  final _IntColumn? orphanScore;
  final _BoolColumn flag;
  final _TextColumn label;
  final _IntColumn value;
  final _TextColumn? desc;
  final _BoolColumn? muted;

  @override
  _ChildRow fromRow(RowReader read) => _ChildRow(
        ownerKey: read(ownerKey)!,
        orphanScore: read(orphanScore),
        flag: read(flag)!,
        label: read(label)!,
        value: read(value)!,
        desc: read(desc),
        muted: read(muted),
      );
}
