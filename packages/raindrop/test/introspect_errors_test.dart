import 'package:raindrop/dialect.dart';
import 'package:raindrop/introspect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final dialect = TestDialect();

  Map<String, Object?> snapshot(List<Schema<dynamic>> schemas) =>
      buildSnapshot(schemas, dialect: dialect, dialectName: 'test').toMap();

  test('two tables with the same name are rejected', () {
    final first = testTable('twice', _SoloSchema.new);
    final second = testTable('twice', _SoloSchema.new);
    expect(
      () => snapshot([first, second]),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('two tables are both named "twice"'),
        ),
      ),
    );
  });

  test('two indexes with the same name are rejected', () {
    final first = testTable('one', _SoloSchema.new, (t) {
      index('clashing').on(t.value);
    });
    final second = testTable('two', _SoloSchema.new, (t) {
      index('clashing').on(t.value);
    });
    expect(
      () => snapshot([first, second]),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('two indexes are both named "clashing"'),
        ),
      ),
    );
  });

  test('a column without a SQL type cannot be snapshotted', () {
    final bare = testTable('bare', _BareSchema.new);
    expect(
      () => snapshot([bare]),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('column "bare.bare" has no sqlType'),
        ),
      ),
    );
  });

  test('an index covering no columns is rejected', () {
    final table = testTable('index_less', _SoloSchema.new);
    table.$.addIndex(Index('covers_nothing', []));
    expect(
      () => snapshot([table]),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('index "covers_nothing" covers no columns'),
        ),
      ),
    );
  });

  test('NO ACTION and SET DEFAULT render as their ANSI keywords', () {
    final document = snapshot([_parents, _children]);
    final tables = document['tables']! as Map<String, Object?>;
    final children = tables['children']! as Map<String, Object?>;
    final columns = children['columns']! as Map<String, Object?>;
    final parentId = columns['parent_id']! as Map<String, Object?>;

    expect(parentId['foreignKey'], {
      'referencedTable': 'parents',
      'referencedColumn': 'id',
      'onDelete': 'NO ACTION',
      'onUpdate': 'SET DEFAULT',
    });
  });
}

class _Solo {
  _Solo({required this.value, this.id});

  final int? id;
  final int value;
}

class _SoloSchema extends Schema<_Solo> {
  _SoloSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        value = $.integer('value', (s) => s.value);

  final ColumnType<int?> id;
  final ColumnType<int> value;

  @override
  _Solo fromRow(RowReader read) => _Solo(id: read(id), value: read(value));
}

/// A column registered through the core builder, which sets no SQL type.
class _BareSchema extends Schema<int> {
  _BareSchema(super.$) : bare = $.column<int, int>('bare', (i) => i);

  final ColumnType<int> bare;

  @override
  int fromRow(RowReader read) => read(bare);
}

class _Child {
  _Child({required this.parentId, this.id});

  final int? id;
  final int? parentId;
}

class _ChildSchema extends Schema<_Child> {
  _ChildSchema(super.$)
      : id = $.integer('id', (c) => c.id).primaryKey(autoIncrement: true),
        parentId = $.integer('parent_id', (c) => c.parentId).references(
              () => _parents.id,
              onDelete: ReferentialAction.noAction,
              onUpdate: ReferentialAction.setDefault,
            );

  final ColumnType<int?> id;
  final ColumnType<int?> parentId;

  @override
  _Child fromRow(RowReader read) =>
      _Child(id: read(id), parentId: read(parentId));
}

final _SoloSchema _parents = testTable('parents', _SoloSchema.new);

final _ChildSchema _children = testTable('children', _ChildSchema.new);
