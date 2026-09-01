import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/ddl.dart' as entry_point;
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  final generator = entry_point.SQLiteDdlGenerator();

  group('main', () {
    test('wires a generator to the send port', () async {
      final port = ReceivePort();
      entry_point.main([], port.sendPort);

      expect(await port.first, isA<SendPort>());
      port.close();
    });
  });

  group('simple path', () {
    test('a plain nullable add stays an ALTER', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('id', type: 'INTEGER', primaryKey: true)],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('bio', isNullable: true),
            ],
          ),
        ),
      );

      expect(sql, 'ALTER TABLE "users" ADD COLUMN "bio" TEXT;');
    });

    test('a rename stays an ALTER', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(name: 'users', columns: [_column('name')]),
          newTable: TableInfo(name: 'users', columns: [_column('full_name')]),
          renamedColumns: {'name': 'full_name'},
        ),
      );

      expect(
        sql,
        'ALTER TABLE "users" RENAME COLUMN "name" TO "full_name";',
      );
    });
  });

  group('rebuild path', () {
    test('a type change with no dependents is the simple 4-step', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age'),
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age', type: 'INTEGER'),
            ],
          ),
        ),
      );

      expect(sql, '''
PRAGMA defer_foreign_keys = ON;
CREATE TABLE "__new_users" (
  "id" INTEGER PRIMARY KEY,
  "age" INTEGER NOT NULL
);
INSERT INTO "__new_users" ("id", "age") SELECT "id", "age" FROM "users";
DROP TABLE "users";
ALTER TABLE "__new_users" RENAME TO "users";''');
    });

    test('dropped and renamed columns map into the copy', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('name'),
              _column('age'),
              _column('legacy'),
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('full_name'),
              _column('age', type: 'INTEGER'),
            ],
          ),
          renamedColumns: {'name': 'full_name'},
        ),
      );

      expect(
        sql,
        contains(
          '''
INSERT INTO "__new_users" ("id", "full_name", "age") SELECT "id", "name", "age" FROM "users";''',
        ),
      );
      expect(
        sql,
        isNot(contains('legacy')),
        reason: 'a dropped column is absent from the copy and the new table',
      );
    });

    test('dependents are rebuilt: retargeted FK, safe drop order, indexes', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age'),
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age', type: 'INTEGER'),
            ],
          ),
          referencedBy: [
            ReferencedBy(
              table: TableInfo(
                name: 'pets',
                columns: [
                  _column('id', type: 'INTEGER', primaryKey: true),
                  _column(
                    'owner_id',
                    type: 'INTEGER',
                    foreignKey: ForeignKeyInfo(
                      referencedTable: 'users',
                      referencedColumn: 'id',
                      onDelete: 'CASCADE',
                    ),
                  ),
                ],
              ),
              indexes: [
                IndexInfo(
                  name: 'pets_owner',
                  tableName: 'pets',
                  columns: ['owner_id'],
                ),
              ],
            ),
          ],
        ),
      );

      expect(
        sql,
        contains('''
"owner_id" INTEGER NOT NULL REFERENCES "__new_users"("id") ON DELETE CASCADE'''),
      );
      expect(
        sql.indexOf('DROP TABLE "pets";'),
        lessThan(sql.indexOf('DROP TABLE "users";')),
        reason: 'the dependent must drop before the table it references',
      );
      expect(
        sql,
        contains('CREATE INDEX "pets_owner" ON "pets" ("owner_id");'),
      );
    });

    test('dropping a column referenced from elsewhere forces a rebuild', () {
      AlterTable dropB({required String referencedColumn}) {
        return AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('a'), _column('b')],
          ),
          newTable: TableInfo(name: 'users', columns: [_column('a')]),
          referencedBy: [
            ReferencedBy(
              table: TableInfo(
                name: 'pets',
                columns: [
                  _column(
                    'owner_ref',
                    foreignKey: ForeignKeyInfo(
                      referencedTable: 'users',
                      referencedColumn: referencedColumn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      expect(
        generator.generate([dropB(referencedColumn: 'b')]),
        contains('__new_users'),
        reason: 'a dependent FK on the dropped column cannot survive an '
            'in-place DROP COLUMN',
      );
      expect(
        generator.generate([dropB(referencedColumn: 'a')]),
        contains('DROP COLUMN'),
        reason: 'a dependent FK on a surviving column keeps the simple path',
      );
    });

    test('a NOT NULL add without default throws with guidance', () {
      expect(
        () => generator.alterTable(
          AlterTable(
            oldTable: TableInfo(
              name: 'users',
              columns: [_column('id', type: 'INTEGER', primaryKey: true)],
            ),
            newTable: TableInfo(
              name: 'users',
              columns: [
                _column('id', type: 'INTEGER', primaryKey: true),
                _column('email'),
              ],
            ),
          ),
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('generate --empty'),
          ),
        ),
      );
    });

    test('a dependent altered in the same run is rejected', () {
      AlterTable alter(String table,
          {List<ReferencedBy> referencedBy = const []}) {
        return AlterTable(
          oldTable: TableInfo(name: table, columns: [_column('a')]),
          newTable: TableInfo(
            name: table,
            columns: [_column('a', type: 'INTEGER')],
          ),
          referencedBy: referencedBy,
        );
      }

      expect(
        () => generator.generate([
          alter(
            'users',
            referencedBy: [
              ReferencedBy(
                table: TableInfo(
                  name: 'pets',
                  columns: [
                    _column(
                      'owner_id',
                      type: 'INTEGER',
                      foreignKey: ForeignKeyInfo(
                        referencedTable: 'users',
                        referencedColumn: 'id',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          alter('pets'),
        ]),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('separate migrations'),
          ),
        ),
      );
    });
  });

  group('live rebuild', () {
    late Database database;
    late Raindrop db;

    setUp(() {
      database = sqlite3.openInMemory();
      db = Raindrop(SQLiteDelegate(database));
    });

    tearDown(() => database.close());

    test('rebuilding a referenced parent preserves cascade children', () async {
      final setUpSql = '''
CREATE TABLE users (id INTEGER PRIMARY KEY, age TEXT NOT NULL);
CREATE TABLE pets (
  id INTEGER PRIMARY KEY,
  owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX pets_owner ON pets (owner_id);
INSERT INTO users VALUES (1, '30'), (2, '40');
INSERT INTO pets VALUES (10, 1), (20, 2);''';

      final rebuildSql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age'),
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age', type: 'INTEGER'),
            ],
          ),
          referencedBy: [
            ReferencedBy(
              table: TableInfo(
                name: 'pets',
                columns: [
                  _column('id', type: 'INTEGER', primaryKey: true),
                  _column(
                    'owner_id',
                    type: 'INTEGER',
                    foreignKey: ForeignKeyInfo(
                      referencedTable: 'users',
                      referencedColumn: 'id',
                      onDelete: 'CASCADE',
                    ),
                  ),
                ],
              ),
              indexes: [
                IndexInfo(
                  name: 'pets_owner',
                  tableName: 'pets',
                  columns: ['owner_id'],
                ),
              ],
            ),
          ],
        ),
      );

      await migrate(db, [
        Migration('0001_setup', setUpSql),
        Migration('0002_rebuild', rebuildSql),
      ]);

      final pets = database.select('SELECT count(*) AS n FROM pets');
      expect(pets.first['n'], 2, reason: 'children survive the parent rebuild');

      final age = database.select(
        "SELECT type FROM pragma_table_info('users') WHERE name = 'age'",
      );
      expect(age.first['type'], 'INTEGER', reason: 'the type change took');

      final fk = database
          .select("SELECT \"table\" FROM pragma_foreign_key_list('pets')");
      expect(
        fk.first['table'],
        'users',
        reason: "the child's FK points at the rebuilt table, not a shadow",
      );

      final index = database.select(
        """
SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'pets_owner'""",
      );
      expect(index, hasLength(1), reason: "the dependent's index is recreated");

      database.execute('DELETE FROM users WHERE id = 1');
      expect(
        database.select('SELECT count(*) AS n FROM pets').first['n'],
        1,
        reason: 'the recreated FK still cascades a real delete',
      );
    });

    test('a self-referencing table rebuilds intact', () async {
      final setUpSql = '''
CREATE TABLE nodes (
  id INTEGER PRIMARY KEY,
  parent_id INTEGER REFERENCES nodes(id) ON DELETE CASCADE
);
INSERT INTO nodes VALUES (1, NULL), (2, 1);''';

      final rebuildSql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'nodes',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column(
                'parent_id',
                type: 'INTEGER',
                isNullable: true,
                foreignKey: ForeignKeyInfo(
                  referencedTable: 'nodes',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
            ],
          ),
          newTable: TableInfo(
            name: 'nodes',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column(
                'parent_id',
                type: 'INTEGER',
                isNullable: true,
                foreignKey: ForeignKeyInfo(
                  referencedTable: 'nodes',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                ),
              ),
              _column('label', isNullable: true),
            ],
          ),
        ),
      );

      await migrate(db, [
        Migration('0001_setup', setUpSql),
        Migration('0002_rebuild', rebuildSql),
      ]);

      expect(
        database.select('SELECT count(*) AS n FROM nodes').first['n'],
        2,
      );
      final fk = database
          .select("SELECT \"table\" FROM pragma_foreign_key_list('nodes')");
      expect(
        fk.first['table'],
        'nodes',
        reason: 'the self-reference survives the rename dance',
      );

      database.execute('DELETE FROM nodes WHERE id = 1');
      expect(
        database.select('SELECT count(*) AS n FROM nodes').first['n'],
        0,
      );
    });
  });

  group('plain statements', () {
    test('createTable renders keys, defaults, checks and references', () {
      final sql = generator.generate([
        CreateTable(
          TableInfo(
            name: 'pets',
            columns: [
              ColumnInfo(
                name: 'id',
                type: 'INTEGER',
                isNullable: false,
                primaryKey: true,
                autoIncrement: true,
              ),
              ColumnInfo(
                name: 'legs',
                type: 'INTEGER',
                isNullable: false,
                defaultValue: '4',
              ),
              _column(
                'owner_id',
                type: 'INTEGER',
                foreignKey: ForeignKeyInfo(
                  referencedTable: 'owners',
                  referencedColumn: 'id',
                  onDelete: 'CASCADE',
                  onUpdate: 'RESTRICT',
                ),
              ),
            ],
            checks: {'has_legs': '"legs" > 0'},
          ),
        ),
        DropTable('old'),
        DropIndex('old_index', tableName: 'old'),
      ]);

      expect(sql, contains('"id" INTEGER PRIMARY KEY AUTOINCREMENT'));
      expect(sql, contains('"legs" INTEGER NOT NULL DEFAULT 4'));
      expect(
        sql,
        contains(
            'REFERENCES "owners"("id") ON DELETE CASCADE ON UPDATE RESTRICT'),
      );
      expect(sql, contains('CONSTRAINT "has_legs" CHECK ("legs" > 0)'));
      expect(sql, contains('DROP TABLE "old";'));
      expect(sql, contains('DROP INDEX "old_index";'));
    });

    test('a plain column drop stays an ALTER', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('bio')
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('id', type: 'INTEGER', primaryKey: true)],
          ),
        ),
      );

      expect(sql, 'ALTER TABLE "users" DROP COLUMN "bio";');
    });

    test('dropping an indexed column takes the rebuild path', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('bio')
            ],
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('id', type: 'INTEGER', primaryKey: true)],
          ),
          oldIndexes: [
            IndexInfo(name: 'users_bio', tableName: 'users', columns: ['bio']),
          ],
        ),
      );

      expect(sql, contains('CREATE TABLE "__new_users"'));
    });

    test('a shadow table keeps its checks', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [_column('age')],
            checks: {'pos': '"age" > 0'},
          ),
          newTable: TableInfo(
            name: 'users',
            columns: [_column('age', type: 'INTEGER')],
            checks: {'pos': '"age" > 0'},
          ),
        ),
      );

      expect(sql, contains('CONSTRAINT "pos" CHECK ("age" > 0)'));
    });

    test('cyclic foreign keys among the rebuild set throw', () {
      ReferencedBy table(String name, String references) => ReferencedBy(
            table: TableInfo(
              name: name,
              columns: [
                _column(
                  'ref',
                  type: 'INTEGER',
                  foreignKey: ForeignKeyInfo(
                    referencedTable: references,
                    referencedColumn: 'id',
                  ),
                ),
              ],
            ),
          );

      expect(
        () => generator.alterTable(
          AlterTable(
            oldTable: TableInfo(
              name: 'users',
              columns: [_column('age')],
            ),
            newTable: TableInfo(
              name: 'users',
              columns: [_column('age', type: 'INTEGER')],
            ),
            referencedBy: [table('a', 'b'), table('b', 'a')],
          ),
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('Cyclic'),
          ),
        ),
      );
    });
  });
}

ColumnInfo _column(
  String name, {
  String type = 'TEXT',
  bool isNullable = false,
  bool primaryKey = false,
  String? defaultValue,
  ForeignKeyInfo? foreignKey,
}) {
  return ColumnInfo(
    name: name,
    type: type,
    isNullable: isNullable,
    primaryKey: primaryKey,
    defaultValue: defaultValue,
    foreignKey: foreignKey,
  );
}
