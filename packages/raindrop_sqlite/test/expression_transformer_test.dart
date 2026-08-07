import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

enum Rank { bronze, silver, gold }

class _RankTransformer extends ColumnTransformer<Rank, String> {
  const _RankTransformer();

  @override
  String encode(Rank input) => input.name;

  @override
  Rank decode(String input) => Rank.values.byName(input);
}

class _Player {
  _Player({required this.name, this.rank, this.id});

  final int? id;
  final String name;
  final Rank? rank;
}

class _PlayerSchema extends Schema<_Player> {
  _PlayerSchema(super.$)
      : id = $.integer('id', (p) => p.id).primaryKey(autoIncrement: true),
        name = $.text('name', (p) => p.name),
        rank = $.custom<Rank, String, Rank?>(
          'rank',
          (p) => p.rank,
          transformer: const _RankTransformer(),
          sqlType: 'TEXT',
        );

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<Rank?> rank;

  @override
  _Player fromRow(RowReader read) => _Player(
        id: read(id),
        name: read(name)!,
        rank: read(rank),
      );
}

final players = sqliteTable('players', _PlayerSchema.new);

class _SilentLogger implements Logger {
  @override
  void query(String query, List<Object?> values) {}
}

void main() {
  late Database database;
  late Raindrop db;

  setUp(() async {
    database = sqlite3.openInMemory();
    db = Raindrop(SQLiteDelegate(database), logger: _SilentLogger());
    await db.execute(
      'CREATE TABLE players ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'rank TEXT)',
    );
    await db.insert(into: players).values([
      _Player(name: 'Morgan', rank: Rank.gold),
      _Player(name: 'Alex', rank: Rank.silver),
      _Player(name: 'Sam'),
    ]);
  });

  tearDown(() => database.dispose());

  group('an expression over a transformed column', () {
    test('coalesce encodes its fallback and decodes its result', () async {
      final ranks = await db
          .select(Coalesce(players.rank, Rank.bronze))
          .from(players)
          .orderBy({players.name: Order.asc});

      expect(ranks, [Rank.silver, Rank.gold, Rank.bronze]);
    });

    test('the fallback is the one that comes back for a null row', () async {
      final ranks = await db
          .select(Coalesce(players.rank, Rank.bronze))
          .from(players)
          .where(players.name.equals('Sam'));

      expect(ranks.single, Rank.bronze);
    });

    test('the transformer survives two levels of nesting', () async {
      final lowest = await db
          .select(Coalesce(Min(players.rank), Rank.bronze))
          .from(players);

      expect(lowest.single, Rank.gold);
    });

    test('min alone decodes through to the domain type', () async {
      final lowest = await db.select(min(players.rank)).from(players);
      expect(lowest.single, Rank.gold);
    });

    test('count stays an int and is not run through the transformer', () async {
      final counted = await db.select(count(players.rank)).from(players);
      expect(counted.single, 2);
    });

    test('a predicate against an expression compares stored forms', () async {
      final matched = await db
          .select(players.name)
          .from(players)
          .where(players.rank.equals(Coalesce(players.rank, Rank.bronze)));

      expect(matched, containsAll(['Morgan', 'Alex']));
    });
  });

  group('the transformer itself', () {
    test('is taken from the operand, not declared', () {
      expect(Coalesce(players.rank, Rank.bronze).transformer, isNotNull);
      expect(Min(players.rank).transformer, isNotNull);
      expect(Coalesce(Min(players.rank), Rank.bronze).transformer, isNotNull);
    });

    test('is absent where the expression changes the type it produces', () {
      expect(Count(players.rank).transformer, isNull);
      expect(Coalesce(players.name, 'anon').transformer, isNull);
    });

    test('an expression nests inside another expression', () async {
      final lowest = await db
          .select(Min(Coalesce(players.rank, Rank.bronze)))
          .from(players);

      expect(lowest.single, Rank.bronze);
    });
  });
}
