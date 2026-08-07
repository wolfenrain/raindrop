import 'dart:isolate';

import 'package:raindrop/ddl.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_sqlite/src/sqlite_ddl.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

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

void main() {
  late ReceivePort port;
  late SQLiteDdlGenerator generator;

  setUp(() {
    port = ReceivePort();
    generator = SQLiteDdlGenerator(port.sendPort);
  });

  tearDown(() {
    generator.dispose();
    port.close();
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
          renamedColumns: const {'name': 'full_name'},
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
              _column('age', type: 'TEXT'),
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
              _column('age', type: 'TEXT'),
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
          renamedColumns: const {'name': 'full_name'},
        ),
      );

      expect(
        sql,
        contains(
          'INSERT INTO "__new_users" ("id", "full_name", "age") '
          'SELECT "id", "name", "age" FROM "users";',
        ),
      );
      // "legacy" is dropped: absent from the copy, and from the new table.
      expect(sql, isNot(contains('legacy')));
    });

    test('dependents are rebuilt: retargeted FK, safe drop order, indexes', () {
      final sql = generator.alterTable(
        AlterTable(
          oldTable: TableInfo(
            name: 'users',
            columns: [
              _column('id', type: 'INTEGER', primaryKey: true),
              _column('age', type: 'TEXT'),
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
                    foreignKey: const ForeignKeyInfo(
                      referencedTable: 'users',
                      referencedColumn: 'id',
                      onDelete: 'CASCADE',
                    ),
                  ),
                ],
              ),
              indexes: const [
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
        contains('"owner_id" INTEGER NOT NULL REFERENCES "__new_users"("id") '
            'ON DELETE CASCADE'),
      );
      // The dependent must be dropped BEFORE the table it references.
      expect(
        sql.indexOf('DROP TABLE "pets";'),
        lessThan(sql.indexOf('DROP TABLE "users";')),
      );
      expect(
        sql,
        contains('CREATE INDEX "pets_owner" ON "pets" ("owner_id");'),
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
                      foreignKey: const ForeignKeyInfo(
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

  group('live rebuild (the drizzle regression)', () {
    late Database database;
    late Raindrop db;

    setUp(() {
      database = sqlite3.openInMemory();
      database.execute('PRAGMA foreign_keys = ON;');
      db = Raindrop(SQLiteDelegate(database));
    });

    tearDown(() => database.dispose());

    test('rebuilding a referenced parent preserves cascade children', () async {
      const setUpSql = '''
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
              _column('age', type: 'TEXT'),
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
                    foreignKey: const ForeignKeyInfo(
                      referencedTable: 'users',
                      referencedColumn: 'id',
                      onDelete: 'CASCADE',
                    ),
                  ),
                ],
              ),
              indexes: const [
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
        const Migration('0001_setup', setUpSql),
        Migration('0002_rebuild', rebuildSql),
      ]);

      // Children survived the parent rebuild (drizzle wipes them here).
      final pets = database.select('SELECT count(*) AS n FROM pets');
      expect(pets.first['n'], 2);

      // The type change took.
      final age = database.select(
        "SELECT type FROM pragma_table_info('users') WHERE name = 'age'",
      );
      expect(age.first['type'], 'INTEGER');

      // The child's FK points at the rebuilt table, not a shadow.
      final fk = database
          .select("SELECT \"table\" FROM pragma_foreign_key_list('pets')");
      expect(fk.first['table'], 'users');

      // The dependent's index was recreated.
      final index = database.select(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'pets_owner'",
      );
      expect(index, hasLength(1));

      // Enforcement still works: a real delete cascades.
      database.execute('DELETE FROM users WHERE id = 1');
      expect(
        database.select('SELECT count(*) AS n FROM pets').first['n'],
        1,
      );
    });

    test('a self-referencing table rebuilds intact', () async {
      const setUpSql = '''
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
                foreignKey: const ForeignKeyInfo(
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
                foreignKey: const ForeignKeyInfo(
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
        const Migration('0001_setup', setUpSql),
        Migration('0002_rebuild', rebuildSql),
      ]);

      expect(
        database.select('SELECT count(*) AS n FROM nodes').first['n'],
        2,
      );
      // The self-reference survived the rename dance.
      final fk = database
          .select("SELECT \"table\" FROM pragma_foreign_key_list('nodes')");
      expect(fk.first['table'], 'nodes');

      // And still cascades.
      database.execute('DELETE FROM nodes WHERE id = 1');
      expect(
        database.select('SELECT count(*) AS n FROM nodes').first['n'],
        0,
      );
    });
  });
}
