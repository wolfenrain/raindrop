import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  final user = _User(email: 'a@b.c', name: 'first');

  group('onConflict', () {
    test('doNothing renders its conflict target', () {
      final (sql, values) = _render(
        _db
            .insert(into: _users)
            .values([user]).onConflict([_users.email]).doNothing(),
      );

      expect(sql, endsWith('ON CONFLICT ("email") DO NOTHING'));
      expect(values, ['a@b.c', 'first']);
    });

    test('a bare onConflict renders without a target', () {
      final (sql, _) = _render(
        _db.insert(into: _users).values([user]).onConflict().doNothing(),
      );

      expect(sql, endsWith('ON CONFLICT DO NOTHING'));
    });

    test('a multi-column target renders comma separated', () {
      final (sql, _) = _render(
        _db
            .insert(into: _users)
            .values([user]).onConflict([_users.email, _users.name]).doNothing(),
      );

      expect(sql, endsWith('ON CONFLICT ("email", "name") DO NOTHING'));
    });

    test('doUpdate renders assignments and binds their values', () {
      final (sql, values) = _render(
        _db.insert(into: _users).values([user]).onConflict(
            [_users.email]).doUpdate([_users.name.to('updated')]),
      );

      expect(
        sql,
        endsWith(r'ON CONFLICT ("email") DO UPDATE SET "name" = $3'),
      );
      expect(values, ['a@b.c', 'first', 'updated']);
    });

    test('doUpdate renders multiple assignments comma separated', () {
      final (sql, values) = _render(
        _db.insert(into: _users).values([user]).onConflict(
          [_users.email],
        ).doUpdate([_users.name.to('updated'), _users.email.to('b@c.d')]),
      );

      expect(sql, endsWith(r'DO UPDATE SET "name" = $3, "email" = $4'));
      expect(values, ['a@b.c', 'first', 'updated', 'b@c.d']);
    });

    test('excluded references the row that failed to insert', () {
      final (sql, values) = _render(
        _db.insert(into: _users).values([user]).onConflict(
            [_users.email]).doUpdate([_users.name.to(excluded(_users.name))]),
      );

      expect(sql, endsWith('DO UPDATE SET "name" = "excluded"."name"'));
      expect(values, ['a@b.c', 'first']);
    });

    test('where narrows the target and the update', () {
      final (sql, _) = _render(
        _db
            .insert(into: _users)
            .values([user])
            .onConflict([_users.email])
            .where(_users.id.isNotNull())
            .doUpdate(
              [_users.name.to(excluded(_users.name))],
              where: _users.name.notEquals('locked'),
            ),
      );

      expect(
        sql,
        endsWith(
          'ON CONFLICT ("email") WHERE "id" IS NOT NULL '
          r'DO UPDATE SET "name" = "excluded"."name" WHERE "name" != $3',
        ),
      );
    });

    test('excluded carries the column transformer', () {
      expect(excluded(_users.name).transformer, isNull);
    });

    test('doUpdate without a target is rejected', () {
      expect(
        () => _db
            .insert(into: _users)
            .values([user])
            .onConflict()
            .doUpdate([_users.name.to('updated')]),
        throwsStateError,
      );
    });

    test('where without a target is rejected', () {
      expect(
        () => _db
            .insert(into: _users)
            .values([user])
            .onConflict()
            .where(_users.id.isNotNull()),
        throwsStateError,
      );
    });

    test('the clause sits between the insert body and RETURNING', () {
      final (sql, _) = _render(
        _db
            .insert(into: _users)
            .values([user])
            .onConflict([_users.email])
            .doNothing()
            .returning(),
      );

      expect(
        sql,
        stringContainsInOrder(['INSERT', 'VALUES', 'ON CONFLICT', 'RETURNING']),
      );
    });
  });
}

class _User {
  _User({required this.email, required this.name, this.id});

  final int? id;
  final String email;
  final String name;
}

class _UserSchema extends Schema<_User> {
  _UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        email = $.text('email', (u) => u.email),
        name = $.text('name', (u) => u.name);

  final ColumnType<int?> id;
  final ColumnType<String> email;
  final ColumnType<String> name;

  @override
  _User fromRow(RowReader read) =>
      _User(id: read(id), email: read(email)!, name: read(name)!);
}

final _UserSchema _users = postgresTable('users', _UserSchema.new);

/// Renders queries through the Postgres dialect without ever executing them.
class _RenderDelegate extends RaindropDelegate {
  _RenderDelegate() : super(dialect: PostgresDialect());

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) {
    throw UnsupportedError('render-only delegate');
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) {
    throw UnsupportedError('render-only delegate');
  }
}

final Raindrop _db = Raindrop(_RenderDelegate());

(String, List<Object?>) _render(QueryBuilder<dynamic, dynamic> builder) {
  final query = (builder as ToQuery<dynamic, dynamic>).compile();
  return PostgresDialect().translate(query);
}
