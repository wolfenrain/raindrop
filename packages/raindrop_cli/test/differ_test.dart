import 'package:raindrop/ddl.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:test/test.dart';

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
            'users_id': const IndexSnapshot(
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
            'users_email': const IndexSnapshot(
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
            'users_id': const IndexSnapshot(
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
              foreignKey: const ForeignKeySnapshotRef(
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
                foreignKey: const ForeignKeySnapshotRef(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
            ]),
          },
          indexes: {
            'users_name': const IndexSnapshot(
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
