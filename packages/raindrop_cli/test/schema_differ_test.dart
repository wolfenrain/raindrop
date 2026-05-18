import 'package:raindrop/ddl.dart';
import 'package:raindrop_cli/src/core/differ.dart';
import 'package:raindrop_cli/src/core/snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaDiffer', () {
    test('recreates unchanged indexes after AlterColumn table rebuild', () {
      const from = SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: 'sqlite',
        id: 'from',
        prevId: SchemaSnapshot.nullUuid,
        tables: {
          'pets': TableSnapshot(
            name: 'pets',
            columns: {
              'id': ColumnSnapshot(
                name: 'id',
                type: 'INTEGER',
                isNullable: true,
                primaryKey: true,
              ),
              'owner_id': ColumnSnapshot(
                name: 'owner_id',
                type: 'INTEGER',
                isNullable: true,
                foreignKey: ForeignKeySnapshotRef(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
            },
          ),
        },
        indexes: {
          'pets_owner': IndexSnapshot(
            name: 'pets_owner',
            tableName: 'pets',
            columns: ['owner_id'],
          ),
        },
      );

      const to = SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: 'sqlite',
        id: 'to',
        prevId: 'from',
        tables: {
          'pets': TableSnapshot(
            name: 'pets',
            columns: {
              'id': ColumnSnapshot(
                name: 'id',
                type: 'INTEGER',
                isNullable: false,
                primaryKey: true,
              ),
              'owner_id': ColumnSnapshot(
                name: 'owner_id',
                type: 'INTEGER',
                isNullable: true,
                foreignKey: ForeignKeySnapshotRef(
                  referencedTable: 'users',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
            },
          ),
        },
        indexes: {
          'pets_owner': IndexSnapshot(
            name: 'pets_owner',
            tableName: 'pets',
            columns: ['owner_id'],
          ),
        },
      );

      final operations = SchemaDiffer().diff(from, to);

      expect(operations.whereType<AlterColumn>(), hasLength(1));
      final alter = operations.whereType<AlterColumn>().single;
      expect(alter.indexes.map((i) => i.name), contains('pets_owner'));
      expect(
        operations.whereType<CreateIndex>().map((op) => op.index.name),
        isNot(contains('pets_owner')),
      );
    });

    test('tableColumns reflects final table state for every AlterColumn', () {
      const from = SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: 'sqlite',
        id: 'from',
        prevId: SchemaSnapshot.nullUuid,
        tables: {
          'users': TableSnapshot(
            name: 'users',
            columns: {
              'name': ColumnSnapshot(
                name: 'name',
                type: 'TEXT',
                isNullable: true,
              ),
              'age': ColumnSnapshot(
                name: 'age',
                type: 'INTEGER',
                isNullable: true,
              ),
            },
          ),
        },
      );

      const to = SchemaSnapshot(
        version: SchemaSnapshot.currentVersion,
        dialect: 'sqlite',
        id: 'to',
        prevId: 'from',
        tables: {
          'users': TableSnapshot(
            name: 'users',
            columns: {
              'name': ColumnSnapshot(
                name: 'name',
                type: 'TEXT',
                isNullable: false,
              ),
              'age': ColumnSnapshot(
                name: 'age',
                type: 'INTEGER',
                isNullable: false,
                defaultValue: '0',
              ),
            },
          ),
        },
      );

      final alters = SchemaDiffer().diff(from, to).whereType<AlterColumn>();

      expect(alters, hasLength(2));
      for (final alter in alters) {
        expect(
          alter.tableColumns.singleWhere((c) => c.name == 'name').isNullable,
          isFalse,
        );
        expect(
          alter.tableColumns.singleWhere((c) => c.name == 'age').defaultValue,
          '0',
        );
        expect(
          alter.tableColumns.singleWhere((c) => c.name == 'age').isNullable,
          isFalse,
        );
      }
    });
  });
}
