import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  group('QueryConfig', () {
    test('exposes every slot it was seeded with', () {
      final filter = users.age.greaterThan(0);
      final join = InnerJoin<Schema<_User>, _User>(users.$, on: filter);
      final assignment = users.name.to('next');
      final order = OrderBy(users.name, descending: false);
      final config = QueryConfig.from({
        #from: users.$,
        #into: users.$,
        #table: users.$,
        #selecting: users.name,
        #where: filter,
        #having: filter,
        #groupBy: users.id,
        #orderBy: [order],
        #joins: [join],
        #set: assignment,
        #values: [1, 2],
        #limit: 5,
        #offset: 2,
        #distinct: true,
      });

      expect(config.from, same(users.$));
      expect(config.into, same(users.$));
      expect(config.table, same(users.$));
      expect(config.selecting, same(users.name));
      expect(config.where, same(filter));
      expect(config.having, same(filter));
      expect(config.groupBy, same(users.id));
      expect(config.orderBy, [order]);
      expect(config.joins, [join]);
      expect(config.set, same(assignment));
      expect(config.values, [1, 2]);
      expect(config.limit, 5);
      expect(config.offset, 2);
      expect(config.distinct, isTrue);
      expect(config.extraClauses, isNull);
      expect(config.get<int>(#limit), 5);
    });

    test('defaults the optional slots', () {
      final config = QueryConfig.from({});

      expect(config.orderBy, isEmpty);
      expect(config.joins, isEmpty);
      expect(config.distinct, isFalse);
      expect(config.get<int>(#limit), isNull);
    });

    test('copyWith merges over the existing entries', () {
      final config = QueryConfig.from({#limit: 1});
      final copy = config.copyWith({#limit: 2, #offset: 3});

      expect(config.limit, 1);
      expect(copy.limit, 2);
      expect(copy.offset, 3);
    });

    test('addClause merges and replaces at the same weight', () {
      final one = QueryConfig.from({}).addClause(10, Keyword('ONE'));
      final two = one.addClause(10, Keyword('TWO'));
      final three = two.addClause(20, Keyword('THREE'));

      expect((one.extraClauses![10]! as Keyword).text, 'ONE');
      expect((two.extraClauses![10]! as Keyword).text, 'TWO');
      expect(three.extraClauses, hasLength(2));
    });
  });

  group('ToQuery', () {
    late TestDelegate delegate;
    late Raindrop db;

    setUp(() {
      delegate = TestDelegate();
      db = Raindrop(delegate);
    });

    test('firsts, lasts and singles', () async {
      delegate.enqueue(_names(['Alex', 'Morgan', 'Sam']));
      final builder =
          db.select(users.name).from(users).orderBy({users.name: Order.asc});

      expect(await builder.first, 'Alex');
      expect(await builder.firstOrNull, 'Alex');
      expect(await builder.last, 'Sam');
      expect(await builder.lastOrNull, 'Sam');

      delegate.enqueue(_names(['Morgan']));
      final one = db.select(users.name).from(users).limit(1);
      expect(await one.single, 'Morgan');
      expect(await one.singleOrNull, 'Morgan');

      // The queue is empty again, so this select sees no rows.
      final none =
          db.select(users.name).from(users).where(users.age.equals(999));
      expect(await none.firstOrNull, isNull);
      expect(await none.lastOrNull, isNull);
      expect(await none.singleOrNull, isNull);
    });

    test('future members delegate to one cached execution', () async {
      delegate.enqueue(_names(['Morgan', 'Alex', 'Sam']));
      final builder = db.select(users.name).from(users);

      expect(await builder.asStream().first, hasLength(3));
      expect(await builder.then((rows) => rows.length), 3);
      expect(await builder.timeout(Duration(seconds: 5)), hasLength(3));
      expect(await builder.whenComplete(() {}), hasLength(3));
      expect(await builder.catchError((Object _) => <String>[]), hasLength(3));

      expect(delegate.statements, hasLength(1));
    });

    test('catchError recovers a failed query', () async {
      final failing = Raindrop(
        TestDelegate(
          onExecute: (sql, values) => throw StateError('no such table'),
        ),
      );
      final builder = failing.select(users.name).from(users);

      expect(await builder.catchError((Object _) => <String>['none']), [
        'none',
      ]);
    });

    test('toString renders the sql of a terminal builder', () {
      expect(
        db.select(users.name).from(users).toString(),
        contains('SELECT "name" FROM "users"'),
      );
    });

    test('toString falls back for a non-terminal builder', () {
      expect(db.update(users).toString(), contains('Instance of'));
    });
  });
}

class _User {
  _User({required this.name, required this.age, this.id});

  final int? id;
  final String name;
  final int age;
}

class _UserSchema extends Schema<_User> {
  _UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name),
        age = $.integer('age', (u) => u.age);

  @override
  _User fromRow(RowReader read) =>
      _User(id: read(id), name: read(name)!, age: read(age)!);

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<int> age;
}

final _UserSchema users = testTable('users', _UserSchema.new);

DatabaseResult _names(List<String> names) => DatabaseResult(
      columns: ['name'],
      rows: [
        for (final name in names) [name],
      ],
      rowsAffected: 0,
      lastInsertedRowId: null,
    );
