import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../_support/fixtures.dart';

/// A table whose primary key spans two columns.
class Score {
  Score({required this.game, required this.player, required this.points});

  final String game;
  final String player;
  final int points;
}

class ScoreSchema extends Schema<Score> {
  ScoreSchema(super.$)
      : game = $.text('game', (s) => s.game).primaryKey(),
        player = $.text('player', (s) => s.player).primaryKey(),
        points = $.integer('points', (s) => s.points);

  @override
  Score fromRow(RowReader read) => Score(
        game: read(game)!,
        player: read(player)!,
        points: read(points)!,
      );

  final ColumnType<String> game;
  final ColumnType<String> player;
  final ColumnType<int> points;
}

final ScoreSchema scores = sqliteTable('scores', ScoreSchema.new);

/// A table that declares no primary key at all.
class Event {
  Event({required this.kind});

  final String kind;
}

class EventSchema extends Schema<Event> {
  EventSchema(super.$) : kind = $.text('kind', (s) => s.kind);

  @override
  Event fromRow(RowReader read) => Event(kind: read(kind)!);

  final ColumnType<String> kind;
}

final EventSchema events = sqliteTable('events', EventSchema.new);

void main() {
  late Database database;
  late Raindrop db;

  int countOf(String table, [String? where]) => database
      .select(
        'SELECT count(*) AS n FROM "$table"'
        '${where == null ? '' : ' WHERE $where'}',
      )
      .first['n'] as int;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: SilentLogger());
    await db.execute(
      '''
CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, "favoriteGame" TEXT NOT NULL, age INTEGER NOT NULL, is_active INTEGER NOT NULL, rating REAL NOT NULL, "deletedAt" INTEGER)''',
    );
    await db.insert(into: users).values([
      User(name: 'Morgan', favoriteGame: 'zelda', age: 30),
      User(name: 'Alex', favoriteGame: 'tetris', age: 28),
      User(name: 'Sam', favoriteGame: 'doom', age: 41),
    ]);
  });

  tearDown(() => database.close());

  group('a capped delete', () {
    test('removes at most the given number of rows', () async {
      await db.delete(from: users).where(users.age.greaterThan(0)).limit(1);

      expect(countOf('users'), 2);
    });

    test('caps only the rows the filter already matched', () async {
      await db.delete(from: users).where(users.age.greaterThan(29)).limit(1);

      final names = database
          .select('SELECT name FROM users ORDER BY name')
          .map((r) => r['name'])
          .toList();
      expect(names, hasLength(2));
      expect(names, contains('Alex'));
    });

    test('deletes every match when the cap exceeds the match count', () async {
      await db.delete(from: users).where(users.age.greaterThan(29)).limit(10);

      expect(countOf('users'), 1);
    });

    test('deletes nothing when the filter matches nothing', () async {
      await db.delete(from: users).where(users.age.greaterThan(200)).limit(5);

      expect(countOf('users'), 3);
    });

    test('yields the removed row when combined with returning', () async {
      final removed = await db
          .delete(from: users)
          .where(users.name.equals('Alex'))
          .limit(1)
          .returning();

      expect(removed.single.name, 'Alex');
      expect(countOf('users'), 2);
    });

    test('caps on a composite primary key', () async {
      await db.execute(
        '''
CREATE TABLE scores (game TEXT NOT NULL, player TEXT NOT NULL, points INTEGER NOT NULL, PRIMARY KEY (game, player))''',
      );
      await db.insert(into: scores).values([
        Score(game: 'zelda', player: 'morgan', points: 10),
        Score(game: 'zelda', player: 'alex', points: 20),
        Score(game: 'doom', player: 'sam', points: 30),
      ]);

      await db.delete(from: scores).where(scores.game.equals('zelda')).limit(1);

      expect(countOf('scores'), 2);
      expect(countOf('scores', "game = 'doom'"), 1);
    });

    test('falls back to rowid when the table declares no primary key',
        () async {
      await db.execute('CREATE TABLE events (kind TEXT NOT NULL)');
      await db.insert(into: events).values([
        Event(kind: 'a'),
        Event(kind: 'a'),
        Event(kind: 'b'),
      ]);

      await db.delete(from: events).where(events.kind.equals('a')).limit(1);

      expect(countOf('events'), 2);
      expect(countOf('events', "kind = 'a'"), 1);
    });

    test('the rowid fallback fails loudly on a WITHOUT ROWID table', () async {
      if (SQLiteDelegate.probeForLimitSupport(database)) {
        markTestSkipped(
          'this library parses a bare DELETE ... LIMIT, so the rowid '
          'fallback never renders',
        );
        return;
      }

      await db.execute(
        'CREATE TABLE events (kind TEXT NOT NULL PRIMARY KEY) WITHOUT ROWID',
      );
      await db.insert(into: events).values([
        Event(kind: 'a'),
        Event(kind: 'b'),
      ]);

      await expectLater(
        db.delete(from: events).where(events.kind.equals('a')).limit(1),
        throwsA(isA<SqliteException>()),
      );
      expect(countOf('events'), 2);
    });
  });

  group('a capped update', () {
    test('changes at most the given number of rows', () async {
      await db
          .update(users)
          .set(users.favoriteGame.to('changed'))
          .where(users.age.greaterThan(0))
          .limit(1);

      expect(countOf('users', '"favoriteGame" = \'changed\''), 1);
    });

    test('caps only the rows the filter already matched', () async {
      await db
          .update(users)
          .set(users.favoriteGame.to('changed'))
          .where(users.age.greaterThan(29))
          .limit(1);

      expect(
          countOf('users', "name = 'Alex' AND \"favoriteGame\" = 'tetris'"), 1);
    });

    test('caps an update that was never filtered', () async {
      await db.update(users).set(users.favoriteGame.to('changed')).limit(2);

      expect(countOf('users', '"favoriteGame" = \'changed\''), 2);
    });

    test('yields the changed row when combined with returning', () async {
      final changed = await db
          .update(users)
          .set(users.favoriteGame.to('changed'))
          .where(users.name.equals('Sam'))
          .limit(1)
          .returning();

      expect(changed.single.favoriteGame, 'changed');
    });
  });

  group('choosing which form to render', () {
    SQLiteDialect dialectOf(SQLiteDelegate delegate) =>
        delegate.dialect as SQLiteDialect;

    test('the probe agrees with what this library actually parses', () {
      final probed = SQLiteDelegate.probeForLimitSupport(database);

      database.execute('CREATE TABLE probe (id INTEGER PRIMARY KEY)');
      var parses = true;
      try {
        database.execute('DELETE FROM probe LIMIT 0');
      } on SqliteException {
        parses = false;
      }

      expect(
        probed,
        parses,
        reason: 'the compile-option answer and the parser must not disagree. '
            'A wrong no only costs a subquery; a wrong yes is a syntax error '
            'the caller meets when the statement runs.',
      );
    });

    test('a delegate probes its library once and keeps the answer', () {
      expect(
        dialectOf(SQLiteDelegate(database)).supportsUpdateDeleteLimit,
        SQLiteDelegate.probeForLimitSupport(database),
      );
    });

    test('a transaction carries the probed dialect, not the default', () async {
      final delegate = SQLiteDelegate(database);

      await delegate.transaction((tx) async {
        expect(identical(tx.dialect, delegate.dialect), isTrue);
      });
    });
  });
}
