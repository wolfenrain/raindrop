// Integration test: runs an explicit column projection across a JOIN (with an
// aggregate + GROUP BY) against a real in-memory engine and asserts the decoded
// typed tuples. SQL-shape coverage lives in the goldens (sql_generation_test);
// this exercises the builder -> dialect -> engine -> decode path end to end.
// ignore_for_file: lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  test('projection + JOIN + aggregate + GROUP BY in one query', () async {
    final db = Raindrop(SQLiteDelegate(sqlite3.openInMemory()));

    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, display_name TEXT)',
    );
    await db.execute(
      'CREATE TABLE runs (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, solve_ms INTEGER, move_count INTEGER, created_at INTEGER)',
    );

    await db.insert(into: users).values(
        [_User(id: 1, displayName: 'ada'), _User(id: 2, displayName: 'lin')]);
    await db.insert(into: runs).values([
      _Run(
        userId: 1,
        solveMs: 500,
        moveCount: 40,
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      ),
      _Run(
        userId: 1,
        solveMs: 300,
        moveCount: 22,
        createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
      ),
      _Run(
        userId: 2,
        solveMs: 900,
        moveCount: 55,
        createdAt: DateTime.fromMillisecondsSinceEpoch(3000),
      ),
    ]);

    final rows = await db
        .select(
          runs.userId,
          min(runs.solveMs),
          runs.moveCount,
          runs.createdAt,
          users.displayName,
        )
        .from(runs)
        .join(users, on: runs.userId.equals(users.id))
        .groupBy(runs.userId)
        .orderBy({runs.userId: Order.asc});

    expect(rows, [
      (1, 300, 22, DateTime.fromMillisecondsSinceEpoch(2000), 'ada'),
      (2, 900, 55, DateTime.fromMillisecondsSinceEpoch(3000), 'lin'),
    ]);
  });
}

class _User {
  _User({required this.id, required this.displayName});

  final int id;

  final String displayName;
}

class _UserSchema extends Schema<_User> {
  _UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        displayName = $.text('display_name', (u) => u.displayName);

  @override
  _User fromRow(RowReader read) =>
      _User(id: read(id)!, displayName: read(displayName)!);

  final ColumnType<int> id;

  final ColumnType<String> displayName;
}

class _Run {
  _Run({
    required this.userId,
    required this.solveMs,
    required this.moveCount,
    required this.createdAt,
    this.id,
  });

  final int? id;

  final int userId;

  final int solveMs;

  final int moveCount;

  final DateTime createdAt;
}

class _RunSchema extends Schema<_Run> {
  _RunSchema(super.$)
      : id = $.integer('id', (r) => r.id).primaryKey(autoIncrement: true),
        userId = $.integer('user_id', (r) => r.userId),
        solveMs = $.integer('solve_ms', (r) => r.solveMs),
        moveCount = $.integer('move_count', (r) => r.moveCount),
        createdAt = $.dateTime('created_at', (r) => r.createdAt);

  @override
  _Run fromRow(RowReader read) => _Run(
        id: read(id),
        userId: read(userId)!,
        solveMs: read(solveMs)!,
        moveCount: read(moveCount)!,
        createdAt: read(createdAt)!,
      );

  final ColumnType<int?> id;

  final ColumnType<int> userId;

  final ColumnType<int> solveMs;

  final ColumnType<int> moveCount;

  final ColumnType<DateTime> createdAt;
}

final _UserSchema users = sqliteTable('users', _UserSchema.new);

final _RunSchema runs = sqliteTable('runs', _RunSchema.new);
