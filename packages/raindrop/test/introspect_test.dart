import 'package:raindrop/dialect.dart';
import 'package:raindrop/introspect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final dialect = TestDialect();

  // No explicit dialectName: the tag filter derives from dialect.name.
  Map<String, Object?> snapshot() =>
      buildSnapshot([owners, pets], dialect: dialect);

  Map<String, Object?> tableOf(String name) =>
      (snapshot()['tables']! as Map)[name] as Map<String, Object?>;

  Map<String, Object?> columnOf(String table, String column) =>
      (tableOf(table)['columns']! as Map)[column] as Map<String, Object?>;

  Map<String, Object?> indexOf(String name) =>
      (snapshot()['indexes']! as Map)[name] as Map<String, Object?>;

  group('the document', () {
    test('carries the identity fields the CLI requires', () {
      final document = snapshot();
      expect(document['version'], snapshotFormatVersion);
      expect(document['dialect'], 'test');
      expect(document['id'], isA<String>());
      expect(document['prevId'], isA<String>());
    });

    test('every table appears, keyed by SQL name', () {
      expect((snapshot()['tables']! as Map).keys, {'owners', 'pets'});
    });

    test('tables for another dialect are skipped', () {
      final document =
          buildSnapshot([owners, pets], dialect: dialect, dialectName: 'other');
      expect(document['tables'], isEmpty);
      expect(document['indexes'], isEmpty);
    });
  });

  group('columns', () {
    test('a plain column reports type and nullability', () {
      expect(columnOf('pets', 'nickname'), {
        'name': 'nickname',
        'type': 'TEXT',
        'primaryKey': false,
        'isNullable': false,
      });
    });

    test('nullability comes from the field type', () {
      expect(columnOf('pets', 'deleted_at')['isNullable'], isTrue);
      expect(columnOf('pets', 'nickname')['isNullable'], isFalse);
    });

    test('autoIncrement is only present when true', () {
      expect(columnOf('owners', 'id')['autoIncrement'], isTrue);
      expect(columnOf('pets', 'id').containsKey('autoIncrement'), isFalse);
    });

    test('a default is emitted under "default"', () {
      expect(columnOf('pets', 'legs')['default'], '4');
      expect(columnOf('pets', 'nickname').containsKey('default'), isFalse);
    });

    test('a default is stored raw, not pre-encoded', () {
      final column = pets.$.columns.firstWhere((c) => c.name == 'friendly');
      expect(column.defaultValue, isA<bool>());
      expect(column.defaultValue, isTrue);
    });

    test('an expression default renders as SQL, not a bound literal', () {
      expect(columnOf('pets', 'born_at')['default'], 'unixepoch()');
    });

    test('a transformed default is encoded then escaped', () {
      expect(columnOf('pets', 'friendly')['default'], "'yes'");
    });

    test('a primary key is flagged', () {
      expect(columnOf('pets', 'id')['primaryKey'], isTrue);
      expect(columnOf('pets', 'legs')['primaryKey'], isFalse);
    });

    test('column order follows declaration order', () {
      expect((tableOf('pets')['columns']! as Map).keys, [
        'id',
        'owner_id',
        'nickname',
        'legs',
        'friendly',
        'born_at',
        'deleted_at',
      ]);
    });
  });

  group('foreign keys', () {
    test('resolve to the referenced SQL names, with actions', () {
      expect(columnOf('pets', 'owner_id')['foreignKey'], {
        'referencedTable': 'owners',
        'referencedColumn': 'id',
        'onDelete': 'CASCADE',
        'onUpdate': 'RESTRICT',
      });
    });

    test('actions are omitted when unset', () {
      expect(columnOf('pets', 'id').containsKey('foreignKey'), isFalse);
    });
  });

  group('indexes', () {
    test('take their table from the columns they cover', () {
      expect(indexOf('idx_pets_owner'), {
        'name': 'idx_pets_owner',
        'tableName': 'pets',
        'columns': ['owner_id'],
        'isUnique': false,
      });
    });

    test('keep column order, which is significant', () {
      expect(indexOf('pets_nickname')['columns'], ['owner_id', 'nickname']);
    });

    test('a Filter predicate is rendered, not dropped', () {
      expect(indexOf('pets_nickname')['where'], '"deleted_at" IS NULL');
    });

    test('a non-partial index has no where key at all', () {
      expect(indexOf('idx_pets_owner').containsKey('where'), isFalse);
    });

    test('the rendered predicate is stable across builds', () {
      expect(
        indexOf('pets_nickname')['where'],
        indexOf('pets_nickname')['where'],
      );
    });
  });

  group('checks', () {
    test('a Filter is rendered, inlined and unqualified', () {
      expect(
        (tableOf('pets')['checks']! as Map)['pets_legs'],
        '"legs" > 0',
      );
    });

    test('a scalar function renders through the same path', () {
      expect(
        (tableOf('pets')['checks']! as Map)['pets_named'],
        'LENGTH("nickname") > 0',
      );
    });

    test('a raw() predicate is passed through verbatim', () {
      expect(
        (tableOf('pets')['checks']! as Map)['pets_one_word'],
        '"nickname" NOT LIKE \'% %\'',
      );
    });

    test('all forms live in the same map, keyed by name', () {
      expect(
        (tableOf('pets')['checks']! as Map).keys,
        {'pets_legs', 'pets_named', 'pets_one_word'},
      );
    });

    test('are omitted entirely when a table has none', () {
      expect(tableOf('owners').containsKey('checks'), isFalse);
    });
  });
}

class _Owner {
  _Owner({required this.name, this.id});

  final int? id;
  final String name;
}

class _OwnerSchema extends Schema<_Owner> {
  _OwnerSchema(super.$)
      : id = $.integer('id', (o) => o.id).primaryKey(autoIncrement: true),
        name = $.text('name', (o) => o.name);

  final ColumnType<int?> id;
  final ColumnType<String> name;

  @override
  _Owner fromRow(RowReader read) => _Owner(id: read(id), name: read(name));
}

/// Stands in for `boolean`/`enumText`: an in-memory type the database does not
/// have, so the stored form differs from the declared one.
class _YesNoTransformer extends ColumnTransformer<bool, String> {
  _YesNoTransformer();

  @override
  String encode(bool input) => input ? 'yes' : 'no';

  @override
  bool decode(String input) => input == 'yes';
}

/// A database-evaluated default, standing in for driver expressions like
/// `unixepoch()` or `now()`.
class _Unixepoch extends Expression<int> {
  const _Unixepoch();

  @override
  SQL build() => SQL.function('unixepoch', const []);
}

class _Pet {
  _Pet({
    required this.id,
    required this.ownerId,
    required this.nickname,
    required this.legs,
    required this.friendly,
    required this.bornAt,
    this.deletedAt,
  });

  final String id;
  final int? ownerId;
  final String nickname;
  final int legs;
  final bool friendly;
  final int bornAt;
  final int? deletedAt;
}

class _PetSchema extends Schema<_Pet> {
  _PetSchema(super.$)
      : id = $.text('id', (p) => p.id).primaryKey(),
        ownerId = $.integer('owner_id', (p) => p.ownerId).references(
              () => owners.id,
              onDelete: ReferentialAction.cascade,
              onUpdate: ReferentialAction.restrict,
            ),
        nickname = $.text('nickname', (p) => p.nickname),
        legs = $.integer('legs', (p) => p.legs, defaultValue: 4),
        // A default the DATABASE evaluates, not a value we supply.
        friendly = $.custom<bool, String, bool>(
          'friendly',
          (p) => p.friendly,
          transformer: _YesNoTransformer(),
          sqlType: 'TEXT',
          defaultValue: true,
        ),
        // A default the DATABASE evaluates, not a value we supply.
        bornAt = $.integer(
          'born_at',
          (p) => p.bornAt,
          defaultValue: _Unixepoch(),
        ),
        deletedAt = $.integer('deleted_at', (p) => p.deletedAt);

  final ColumnType<String> id;
  final ColumnType<int?> ownerId;
  final ColumnType<String> nickname;
  final ColumnType<int> legs;
  final ColumnType<bool> friendly;
  final ColumnType<int> bornAt;
  final ColumnType<int?> deletedAt;

  @override
  _Pet fromRow(RowReader read) => _Pet(
        id: read(id),
        ownerId: read(ownerId),
        nickname: read(nickname),
        legs: read(legs),
        friendly: read(friendly),
        bornAt: read(bornAt),
        deletedAt: read(deletedAt),
      );
}

final _OwnerSchema owners = testTable('owners', _OwnerSchema.new);

final _PetSchema pets = testTable('pets', _PetSchema.new, (t) {
  uniqueIndex('pets_nickname', where: t.deletedAt.isNull())
      .on(t.ownerId, t.nickname);
  index('idx_pets_owner').on(t.ownerId);
  check('pets_legs', t.legs.greaterThan(0)).on(t);
  // The typed spelling of a scalar function.
  check('pets_named', length(t.nickname).greaterThan(0)).on(t);
  // And the escape hatch, for what the DSL cannot say.
  check('pets_one_word', raw('"nickname" NOT LIKE \'% %\'')).on(t);
});
