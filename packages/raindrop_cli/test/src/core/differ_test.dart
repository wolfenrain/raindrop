import 'package:raindrop/ddl.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:test/test.dart';

void main() {
  final differ = SchemaDiffer();

  group('SchemaDiffer', () {
    test('a first snapshot creates every table', () {
      final operations = differ.diff(
        null,
        _snapshot({
          'users': _table('users', [_column('id', primaryKey: true)]),
        }),
      );

      expect(operations, hasLength(1));
      final create = operations.single as CreateTable;
      expect(create.table.name, 'users');
      expect(create.table.columns.single.name, 'id');
    });

    test('an unchanged table emits nothing', () {
      final snapshot = _snapshot({
        'users': _table('users', [_column('id', primaryKey: true)]),
      });

      expect(differ.diff(snapshot, snapshot), isEmpty);
    });

    test('a removed table is dropped, and its indexes are not', () {
      final operations = differ.diff(
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)]),
          },
          indexes: {
            'users_id': IndexSnapshot(
              name: 'users_id',
              tableName: 'users',
              columns: ['id'],
            ),
          },
        ),
        _snapshot({}),
      );

      // No DropIndex: the index dies with its table, and a DropIndex after
      // DropTable would fail at apply time.
      expect(operations.single, isA<DropTable>());
    });

    test('intra-table change becomes ONE AlterTable, checks included', () {
      final operations = differ.diff(
        _snapshot({
          'users': _table(
            'users',
            [_column('id', primaryKey: true), _column('age', type: 'INTEGER')],
            checks: {'age_positive': '"age" > 0'},
          ),
        }),
        _snapshot({
          'users': _table(
            'users',
            [
              _column('id', primaryKey: true),
              _column('age', type: 'INTEGER', isNullable: true),
            ],
            checks: {'age_positive': '"age" >= 0'},
          ),
        }),
      );

      final alter = operations.single as AlterTable;
      final diff = TableDiff.of(alter);
      expect(diff.alteredColumns.single.$1.name, 'age');
      expect(diff.changedChecks, {'age_positive': ('"age" > 0', '"age" >= 0')});
    });

    test('a check-only change flows through instead of throwing', () {
      final operations = differ.diff(
        _snapshot({
          'users': _table(
            'users',
            [_column('id', primaryKey: true)],
            checks: {'c': '1 = 1'},
          ),
        }),
        _snapshot({
          'users': _table('users', [_column('id', primaryKey: true)]),
        }),
      );

      final diff = TableDiff.of(operations.single as AlterTable);
      expect(diff.droppedChecks, {'c': '1 = 1'});
    });

    test('renames are detected into the renames map', () {
      final operations = differ.diff(
        _snapshot({
          'users': _table('users', [_column('name')]),
        }),
        _snapshot({
          'users': _table('users', [_column('full_name')]),
        }),
      );

      final alter = operations.single as AlterTable;
      expect(alter.renamedColumns, {'name': 'full_name'});
      final diff = TableDiff.of(alter);
      expect(diff.addedColumns, isEmpty);
      expect(diff.droppedColumns, isEmpty);
    });

    test('index changes on an altered table travel ON the operation', () {
      final operations = differ.diff(
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)]),
          },
        ),
        _snapshot(
          {
            'users': _table(
              'users',
              [_column('id', primaryKey: true), _column('email')],
            ),
          },
          indexes: {
            'users_email': IndexSnapshot(
              name: 'users_email',
              tableName: 'users',
              columns: ['email'],
              isUnique: true,
            ),
          },
        ),
      );

      // One op owns the whole table: no global CreateIndex alongside.
      final alter = operations.single as AlterTable;
      expect(alter.newIndexes.single.name, 'users_email');
      expect(TableDiff.of(alter).addedIndexes.single.isUnique, isTrue);
    });

    test('an index-only change on an otherwise untouched table is global', () {
      final operations = differ.diff(
        _snapshot({
          'users': _table('users', [_column('id', primaryKey: true)]),
        }),
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)]),
          },
          indexes: {
            'users_id': IndexSnapshot(
              name: 'users_id',
              tableName: 'users',
              columns: ['id'],
            ),
          },
        ),
      );

      // Index-only means the table DID change (its indexes are part of it),
      // so it comes out as an AlterTable carrying only index changes.
      final alter = operations.single as AlterTable;
      final diff = TableDiff.of(alter);
      expect(diff.addedIndexes, hasLength(1));
      expect(diff.addedColumns, isEmpty);
      expect(diff.alteredColumns, isEmpty);
    });

    test('the same indexes in a different snapshot order emit nothing', () {
      // Two indexes on one table, reordered. Nothing changed, so nothing may
      // be emitted: an AlterTable here carries an EMPTY TableDiff, which the
      // dialect renders as no SQL at all and DdlGenerator then throws on --
      // `Alter table "subscriptions" () produced no SQL`, on a schema nobody
      // touched. Reported by Picto, 2026-08-14.
      IndexSnapshot index(String name, String column) => IndexSnapshot(
            name: name,
            tableName: 'subscriptions',
            columns: [column],
          );
      final byUser = index('subscriptions_user_id', 'user_id');
      final byStatus = index('subscriptions_status', 'status');

      final tables = {
        'subscriptions': _table('subscriptions', [
          _column('id', primaryKey: true),
          _column('user_id'),
          _column('status'),
        ]),
      };

      expect(
        differ.diff(
          _snapshot(
            tables,
            indexes: {byUser.name: byUser, byStatus.name: byStatus},
          ),
          _snapshot(
            tables,
            indexes: {byStatus.name: byStatus, byUser.name: byUser},
          ),
        ),
        isEmpty,
      );
    });

    test('an orphan index is dropped on its own', () {
      final operations = differ.diff(
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)])
          },
          indexes: {
            'ghost': IndexSnapshot(
              name: 'ghost',
              tableName: 'phantom',
              columns: ['x'],
            ),
          },
        ),
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)])
          },
        ),
      );

      final drop = operations.single as DropIndex;
      expect(drop.indexName, 'ghost');
    });

    test('a changed orphan index is dropped and recreated', () {
      IndexSnapshot ghost({required bool isUnique}) => IndexSnapshot(
            name: 'ghost',
            tableName: 'phantom',
            columns: ['x'],
            isUnique: isUnique,
          );
      final operations = differ.diff(
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)])
          },
          indexes: {'ghost': ghost(isUnique: false)},
        ),
        _snapshot(
          {
            'users': _table('users', [_column('id', primaryKey: true)])
          },
          indexes: {'ghost': ghost(isUnique: true)},
        ),
      );

      expect(operations, hasLength(2));
      expect(operations.first, isA<DropIndex>());
      expect(operations.last, isA<CreateIndex>());
    });

    group('referencedBy closure', () {
      ForeignKeySnapshotRef fk(String table, [String column = 'id']) =>
          ForeignKeySnapshotRef(
            referencedTable: table,
            referencedColumn: column,
            onDelete: 'CASCADE',
          );

      test('direct and transitive dependents are carried', () {
        final operations = differ.diff(
          _snapshot({
            'users': _table('users', [_column('id', primaryKey: true)]),
            'pets': _table('pets', [
              _column('id', primaryKey: true),
              _column('owner_id', type: 'INTEGER', foreignKey: fk('users')),
            ]),
            'toys': _table('toys', [
              _column('id', primaryKey: true),
              _column('pet_id', type: 'INTEGER', foreignKey: fk('pets')),
            ]),
            'rooms': _table('rooms', [_column('id', primaryKey: true)]),
          }),
          _snapshot({
            'users': _table('users', [
              _column('id', primaryKey: true),
              _column('age', type: 'INTEGER', isNullable: true),
            ]),
            'pets': _table('pets', [
              _column('id', primaryKey: true),
              _column('owner_id', type: 'INTEGER', foreignKey: fk('users')),
            ]),
            'toys': _table('toys', [
              _column('id', primaryKey: true),
              _column('pet_id', type: 'INTEGER', foreignKey: fk('pets')),
            ]),
            'rooms': _table('rooms', [_column('id', primaryKey: true)]),
          }),
        );

        final alter = operations.single as AlterTable;
        expect(
          alter.referencedBy.map((r) => r.table.name),
          ['pets', 'toys'],
        );
      });

      test('a self-reference is not its own dependent', () {
        final operations = differ.diff(
          _snapshot({
            'nodes': _table('nodes', [
              _column('id', primaryKey: true),
              _column(
                'parent_id',
                type: 'INTEGER',
                isNullable: true,
                foreignKey: fk('nodes'),
              ),
            ]),
          }),
          _snapshot({
            'nodes': _table('nodes', [
              _column('id', primaryKey: true),
              _column(
                'parent_id',
                type: 'INTEGER',
                isNullable: true,
                foreignKey: fk('nodes'),
              ),
              _column('label', isNullable: true),
            ]),
          }),
        );

        final alter = operations.single as AlterTable;
        expect(alter.referencedBy, isEmpty);
      });
    });

    test('operations survive a serialization round-trip', () {
      final operations = differ.diff(
        _snapshot({
          'users': _table('users', [_column('id', primaryKey: true)]),
          'pets': _table('pets', [
            _column('id', primaryKey: true),
            _column(
              'owner_id',
              type: 'INTEGER',
              foreignKey: ForeignKeySnapshotRef(
                referencedTable: 'users',
                referencedColumn: 'id',
                onDelete: 'CASCADE',
              ),
            ),
          ]),
        }),
        _snapshot(
          {
            'users': _table(
              'users',
              [_column('id', primaryKey: true), _column('name')],
              checks: {'named': "\"name\" != ''"},
            ),
            'pets': _table('pets', [
              _column('id', primaryKey: true),
              _column(
                'owner_id',
                type: 'INTEGER',
                foreignKey: ForeignKeySnapshotRef(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
            ]),
          },
          indexes: {
            'users_name': IndexSnapshot(
              name: 'users_name',
              tableName: 'users',
              columns: ['name'],
            ),
          },
        ),
      );

      for (final operation in operations) {
        final restored = DiffOperation.fromMap(operation.toMap());
        expect(restored.toMap(), operation.toMap());
        expect(restored.describe(), operation.describe());
      }
    });
  });
}

SchemaSnapshot _snapshot(
  Map<String, TableSnapshot> tables, {
  Map<String, IndexSnapshot> indexes = const {},
}) {
  return SchemaSnapshot(
    version: SchemaSnapshot.currentVersion,
    dialect: 'sqlite',
    id: SchemaSnapshot.nullUuid,
    prevId: SchemaSnapshot.nullUuid,
    tables: tables,
    indexes: indexes,
  );
}

TableSnapshot _table(
  String name,
  List<ColumnSnapshot> columns, {
  Map<String, String> checks = const {},
}) {
  return TableSnapshot(
    name: name,
    columns: {for (final column in columns) column.name: column},
    checks: checks,
  );
}

ColumnSnapshot _column(
  String name, {
  String type = 'TEXT',
  bool isNullable = false,
  bool primaryKey = false,
  String? defaultValue,
  ForeignKeySnapshotRef? foreignKey,
}) {
  return ColumnSnapshot(
    name: name,
    type: type,
    isNullable: isNullable,
    primaryKey: primaryKey,
    defaultValue: defaultValue,
    foreignKey: foreignKey,
  );
}
