import 'package:raindrop/dialect.dart';
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

  /// Queues one result whose single row holds [values].
  void enqueueRow(List<Object?> values) {
    delegate.enqueue(
      DatabaseResult(
        columns: [for (var i = 0; i < values.length; i++) 'c$i'],
        rows: [values],
        rowsAffected: 0,
        lastInsertedRowId: null,
      ),
    );
  }

  group('run', () {
    test('decodes record rows at every supported arity', () async {
      enqueueRow([1]);
      final one = db.select(users.id).from(users).limit(1);
      expect(await one, [1]);

      enqueueRow([1, 'Morgan']);
      final two = db.select(users.id, users.name).from(users).limit(1);
      expect(await two, [(1, 'Morgan')]);

      enqueueRow([1, 'Morgan', 30]);
      final three =
          db.select(users.id, users.name, users.age).from(users).limit(1);
      expect(await three, [(1, 'Morgan', 30)]);

      enqueueRow([1, 'Morgan', 30, 6]);
      final four = db
          .select(users.id, users.name, users.age, length(users.name))
          .from(users)
          .limit(1);
      expect(await four, [(1, 'Morgan', 30, 6)]);

      enqueueRow([1, 'Morgan', 30, 6, 'MORGAN']);
      final five = db
          .select(
            users.id,
            users.name,
            users.age,
            length(users.name),
            upper(users.name),
          )
          .from(users)
          .limit(1);
      expect(await five, [(1, 'Morgan', 30, 6, 'MORGAN')]);

      enqueueRow([1, 'Morgan', 30, 6, 'MORGAN', 'morgan']);
      final six = db
          .select(
            users.id,
            users.name,
            users.age,
            length(users.name),
            upper(users.name),
            lower(users.name),
          )
          .from(users)
          .limit(1);
      expect(await six, [(1, 'Morgan', 30, 6, 'MORGAN', 'morgan')]);

      enqueueRow([1, 'Morgan', 30, 6, 'MORGAN', 'morgan', 'Morgan']);
      final seven = db
          .select(
            users.id,
            users.name,
            users.age,
            length(users.name),
            upper(users.name),
            lower(users.name),
            trim(users.name),
          )
          .from(users)
          .limit(1);
      expect(await seven, [(1, 'Morgan', 30, 6, 'MORGAN', 'morgan', 'Morgan')]);

      enqueueRow([1, 'Morgan', 30, 6, 'MORGAN', 'morgan', 'Morgan', 30]);
      final eight = db
          .select(
            users.id,
            users.name,
            users.age,
            length(users.name),
            upper(users.name),
            lower(users.name),
            trim(users.name),
            abs(users.age),
          )
          .from(users)
          .limit(1);
      expect(await eight, [
        (1, 'Morgan', 30, 6, 'MORGAN', 'morgan', 'Morgan', 30),
      ]);
    });

    test('refuses record rows wider than eight', () async {
      enqueueRow([1, 'Morgan', 30, 6, 'MORGAN', 'morgan', 'Morgan', 30, 1]);
      final nine = db
          .select(
            users.id,
            users.name,
            users.age,
            length(users.name),
            upper(users.name),
            lower(users.name),
            trim(users.name),
            abs(users.age),
            users.id,
          )
          .from(users)
          .limit(1);

      await expectLater(nine, throwsUnsupportedError);
    });

    test('decodes a schema shape through its table', () async {
      delegate.enqueue(
        DatabaseResult(
          columns: ['id', 'name', 'age'],
          rows: [
            [1, 'Morgan', 30],
          ],
          rowsAffected: 0,
          lastInsertedRowId: null,
        ),
      );
      final query = Query<_User>(
        shape: users,
        clauses: {
          SelectSlot.verb: Keyword('SELECT'),
          SelectSlot.columns: SelectionClause(users.$),
          SelectSlot.from: FromClause(users.$),
        },
      );

      final rows = await db.run(query);

      expect(rows.first.name, 'Morgan');
      expect(rows.first.age, 30);
    });

    test('records the sql on the active span when tracing', () async {
      Raindrop.tracer.isTracing = true;
      addTearDown(() => Raindrop.tracer.isTracing = false);
      delegate.enqueue(
        DatabaseResult(
          columns: ['name'],
          rows: [
            ['Morgan'],
            ['Alex'],
          ],
          rowsAffected: 0,
          lastInsertedRowId: null,
        ),
      );

      final names = await db.select(users.name).from(users);

      expect(names, hasLength(2));
      expect('${Raindrop.tracer.dump()}', contains('RaindropExecutor.run'));
    });

    test('throws for a selectable it cannot decode', () async {
      enqueueRow([1]);
      final query = Query<int>(
        shape: _OpaqueSelectable(),
        clauses: {SelectSlot.verb: Keyword('SELECT 1')},
      );

      await expectLater(db.run(query), throwsUnimplementedError);
    });
  });

  group('execute guards', () {
    test('refuses the main executor inside a transaction', () async {
      await expectLater(
        db.transaction((tx) => db.execute('SELECT 1')),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('main database executor'),
          ),
        ),
      );
    });

    test('refuses a parent executor inside a nested transaction', () async {
      await expectLater(
        db.transaction(
          (tx) => tx.transaction((inner) => tx.execute('SELECT 1')),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('parent transaction executor'),
          ),
        ),
      );
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

/// A selectable shape the executor has no decoding strategy for.
class _OpaqueSelectable implements Selectable<int> {}
