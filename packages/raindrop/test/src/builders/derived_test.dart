import 'package:raindrop/dialect.dart';
import 'package:raindrop/src/builders/derived.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  late TestDelegate delegate;
  late Raindrop db;

  setUp(() {
    delegate = TestDelegate();
    db = Raindrop(delegate);
  });

  String sqlOf(Object builder) =>
      TestDialect().translate((builder as ToQuery).compile()).$1;

  /// Queues one result of [rows] under [columns].
  void enqueue(List<String> columns, List<List<Object?>> rows) {
    delegate.enqueue(
      DatabaseResult(
        columns: columns,
        rows: rows,
        rowsAffected: 0,
        lastInsertedRowId: null,
      ),
    );
  }

  group('whole-row derived', () {
    test('selects whole rows through the derived table', () async {
      final owned =
          db.select().from(pets).where(pets.ownerId.equals(1)).derived();

      expect(sqlOf(db.select().from(owned)), contains('FROM (SELECT'));

      enqueue([
        'id',
        'owner_id',
        'name',
        'rank'
      ], [
        [1, 1, 'Rex', 'gold'],
        [2, 1, 'Milo', 'silver'],
      ]);
      final rows = await db.select().from(owned);
      expect(rows.map((p) => p.name), containsAll(['Rex', 'Milo']));
    });

    test('base column handles resolve against it', () async {
      final owned =
          db.select().from(pets).where(pets.ownerId.equals(1)).derived();

      enqueue([
        'name'
      ], [
        ['Rex'],
      ]);
      final names = await db
          .select(pets.name)
          .from(owned)
          .where(pets.rank.equals(_Rank.gold));

      expect(names, ['Rex']);
    });

    test('throws when there is nothing to select from', () {
      final builder = WholeRowFromBuilder<_PetSchema, _Pet>(
        db,
        config: QueryConfig.from({}),
      );

      expect(builder.derived, throwsStateError);
    });
  });

  group('projection derived', () {
    test('names a bare aggregate and aggregates over it', () async {
      final counts = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final sql = sqlOf(db.select(min(counts.$2)).from(counts));
      expect(sql, contains('COUNT("id") AS "c1"'));
      expect(sql, contains('AS "pets_d"'));

      enqueue([
        'min'
      ], [
        [1],
      ]);
      final fewest = await db.select(min(counts.$2)).from(counts);
      expect(fewest.single, 1);
    });

    test('a one-column projection derives', () async {
      final counts =
          db.select(pets.id.count()).from(pets).groupBy(pets.ownerId).derived();

      enqueue([
        'min'
      ], [
        [1],
      ]);
      final fewest = await db.select(min(counts.$1)).from(counts);

      expect(fewest.single, 1);
    });

    test('an aliased expression keeps its own name', () {
      final counts = db
          .select(pets.ownerId, pets.id.count().as('total'))
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final sql = sqlOf(db.select(min(counts.$2)).from(counts));

      expect(sql, contains('AS "total"'));
      expect(sql, contains('MIN("total")'));
      expect(sql, isNot(contains('"c1"')));
    });

    test('an aliased column keeps its alias', () {
      final derived = db
          .select(pets.name.as('nick'), pets.id.count())
          .from(pets)
          .groupBy(pets.name)
          .derived();

      final sql = sqlOf(db.select(derived.$1).from(derived));

      expect(sql, contains('AS "nick"'));
    });

    test('a generated name steps around one already in use', () {
      final derived = db
          .select(pets.name.as('c1'), pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final sql = sqlOf(db.select(derived.$2).from(derived));

      expect(sql, contains('AS "c1"'));
      expect(sql, isNot(contains('COUNT("id") AS "c1"')));
    });

    test('can be named explicitly', () {
      final counts = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived(as: 'by_owner');

      expect(
        sqlOf(db.select(min(counts.$2)).from(counts)),
        contains('AS "by_owner"'),
      );
    });

    test('refuses a projection it cannot name', () {
      expect(
        () => db.select(pets, pets.name).from(pets).derived(),
        throwsUnsupportedError,
      );
    });
  });

  group('transformers', () {
    test('survive into the derived row', () async {
      final ranked = db.select(pets.rank, pets.name).from(pets).derived();

      enqueue([
        'rank',
        'name'
      ], [
        ['gold', 'Rex'],
        ['silver', 'Milo'],
      ]);
      final rows = await db.select().from(ranked);

      expect(rows.map((r) => r.$1), containsAll([_Rank.gold, _Rank.silver]));
    });

    test('and through a handle used in the outer query', () async {
      final ranked = db.select(pets.rank, pets.name).from(pets).derived();

      enqueue([
        'min'
      ], [
        ['bronze'],
      ]);
      final lowest = await db.select(min(ranked.$1)).from(ranked);

      expect(lowest.single, _Rank.bronze);
    });
  });

  group('defaultDerivedName', () {
    test('derives its name from the source table', () {
      expect(defaultDerivedName(QueryConfig.from({#from: pets.$})), 'pets_d');
    });

    test('falls back without a source table', () {
      expect(defaultDerivedName(QueryConfig.from({})), 'derived');
    });
  });
}

enum _Rank { bronze, silver, gold }

class _RankTransformer extends ColumnTransformer<_Rank, String> {
  _RankTransformer();

  @override
  String encode(_Rank input) => input.name;

  @override
  _Rank decode(String input) => _Rank.values.byName(input);
}

class _Pet {
  _Pet({required this.ownerId, required this.name, this.rank, this.id});

  final int? id;
  final int ownerId;
  final String name;
  final _Rank? rank;
}

class _PetSchema extends Schema<_Pet> {
  _PetSchema(super.$)
      : id = $.integer('id', (p) => p.id).primaryKey(autoIncrement: true),
        ownerId = $.integer('owner_id', (p) => p.ownerId),
        name = $.text('name', (p) => p.name),
        rank = $.custom<_Rank, String, _Rank?>(
          'rank',
          (p) => p.rank,
          transformer: _RankTransformer(),
          sqlType: 'TEXT',
        );

  @override
  _Pet fromRow(RowReader read) => _Pet(
        id: read(id),
        ownerId: read(ownerId)!,
        name: read(name)!,
        rank: read(rank),
      );

  final ColumnType<int?> id;
  final ColumnType<int> ownerId;
  final ColumnType<String> name;
  final ColumnType<_Rank?> rank;
}

final _PetSchema pets = testTable('pets', _PetSchema.new);
