import 'package:raindrop/dialect.dart';
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

class Pet {
  Pet({required this.name, required this.ownerId, this.rank, this.id});
  final int? id;
  final int ownerId;
  final String name;
  final Rank? rank;
}

class PetSchema extends Schema<Pet> {
  PetSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        ownerId = $.integer('owner_id', (s) => s.ownerId),
        name = $.text('name', (s) => s.name),
        rank = $.custom<Rank, String, Rank?>(
          'rank',
          (s) => s.rank,
          transformer: const _RankTransformer(),
          sqlType: 'TEXT',
        );

  @override
  Pet fromRow(RowReader read) => Pet(
        id: read(id),
        ownerId: read(ownerId)!,
        name: read(name)!,
        rank: read(rank),
      );

  final ColumnType<int?> id;
  final ColumnType<int> ownerId;
  final ColumnType<String> name;
  final ColumnType<Rank?> rank;
}

final pets = sqliteTable('pets', PetSchema.new);

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
      'CREATE TABLE pets (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'owner_id INTEGER NOT NULL, name TEXT NOT NULL, rank TEXT)',
    );
    await db.insert(into: pets).values([
      Pet(name: 'Rex', ownerId: 1, rank: Rank.gold),
      Pet(name: 'Milo', ownerId: 1, rank: Rank.silver),
      Pet(name: 'Smokey', ownerId: 2, rank: Rank.bronze),
    ]);
  });

  tearDown(() => database.dispose());

  String sqlOf(Object builder) =>
      const SQLiteDialect().translate((builder as ToQuery).compile()).$1;

  group('the motivating case', () {
    // A nested aggregate is invalid SQL everywhere except Oracle/MySQL. This
    // is the portable spelling, and the reason the feature exists.
    test('MIN over COUNT through a derived table', () async {
      final counts = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final fewest = await db.select(min(counts.$2)).from(counts);

      expect(fewest.single, 1);
    });

    test('renders as a named statement, with the aggregate aliased', () {
      final counts = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final sql = sqlOf(db.select(min(counts.$2)).from(counts));

      expect(sql, contains('COUNT("id") AS "c1"'));
      expect(sql, contains('AS "pets_d"'));
      expect(sql, contains('MIN("c1")'));
    });
  });

  group('typing', () {
    test('the whole derived table comes back as the record', () async {
      final counts = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final rows = await db.select().from(counts);

      expect(rows, isA<List<(int, int)>>());
      expect(rows, containsAll(<(int, int)>[(1, 2), (2, 1)]));
    });

    // The nested aggregate without carrying the group key, which is the whole
    // point of supporting a one-column projection.
    test('a one-column projection derives', () async {
      final counts =
          db.select(pets.id.count()).from(pets).groupBy(pets.ownerId).derived();

      final fewest = await db.select(min(counts.$1)).from(counts);

      expect(fewest.single, 1);
    });

    test('a one-column derived table returns a 1-tuple', () async {
      final counts =
          db.select(pets.id.count()).from(pets).groupBy(pets.ownerId).derived();

      final rows = await db.select().from(counts);

      expect(rows, isA<List<(int,)>>());
      expect(rows, containsAll(<(int,)>[(2,), (1,)]));
    });

    // A plain one-column select must still yield the bare element type.
    test('one-column selects are unchanged', () async {
      final List<int> owners =
          await db.select(pets.ownerId).from(pets).orderBy({
        pets.ownerId: Order.asc,
      });

      expect(owners, [1, 1, 2]);
    });

    test('a record-typed single column still resolves to Derived1', () {
      final inner = subquery(db.select(pets.ownerId, pets.name).from(pets));
      final Derived1<(int, String)> d =
          db.select(inner).from(pets).derived(as: 'one');

      expect(d.$1, isA<ColumnType<(int, String)>>());
    });

    test('a handle can be used bare, not only inside an aggregate', () async {
      final counts = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final owners = await db
          .select(counts.$1)
          .from(counts)
          .orderBy({counts.$1: Order.asc});

      expect(owners, [1, 2]);
    });
  });

  group('naming', () {
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

    // The generated name must not shadow a real column that is already there.
    test('a generated name steps around one already in use', () {
      final derived = db
          .select(pets.name.as('c1'), pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived();

      final sql = sqlOf(db.select(derived.$2).from(derived));

      expect(sql, contains('AS "c1"'));
      // The aggregate had to take something other than c1.
      expect(sql, isNot(contains('COUNT("id") AS "c1"')));
    });

    test('two derived tables in one query can be named apart', () {
      final a = db
          .select(pets.ownerId, pets.id.count())
          .from(pets)
          .groupBy(pets.ownerId)
          .derived(as: 'by_owner');
      final b = db
          .select(pets.name, pets.id.count())
          .from(pets)
          .groupBy(pets.name)
          .derived(as: 'by_name');

      expect(sqlOf(db.select(min(a.$2)).from(a)), contains('AS "by_owner"'));
      expect(sqlOf(db.select(min(b.$2)).from(b)), contains('AS "by_name"'));
    });
  });

  group('transformers', () {
    // read($n) goes through Column.decode, so a synthetic column that lost its
    // transformer would hand back the driver's string instead of the enum.
    test('survive into the derived row', () async {
      final ranked = db.select(pets.rank, pets.name).from(pets).derived();

      final rows = await db.select().from(ranked);

      expect(rows.map((r) => r.$1), everyElement(isA<Rank?>()));
      expect(rows.map((r) => r.$1), containsAll([Rank.gold, Rank.silver]));
    });

    test('and through a handle used in the outer query', () async {
      final ranked = db.select(pets.rank, pets.name).from(pets).derived();

      final lowest = await db.select(min(ranked.$1)).from(ranked);

      // MIN over the STORED form: 'bronze' sorts first.
      expect(lowest.single, Rank.bronze);
    });
  });
}
