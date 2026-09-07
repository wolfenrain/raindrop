import 'package:raindrop/raindrop.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';

// The code under test: a repository that issues queries through raindrop.
class UserRepository {
  const UserRepository(this.db);

  final Raindrop db;

  Future<void> deactivate({required int userId}) => db
      .update(users)
      .set(users.status.to('inactive'))
      .where(users.id.equals(userId));

  Future<List<User>> active() =>
      db.select().from(users).where(users.status.equals('active'));
}

class User {
  const User({required this.name, required this.status, this.id});

  final int? id;

  final String name;

  final String status;

  @override
  String toString() => 'User(id: $id, name: $name, status: $status)';
}

class UserSchema extends Schema<User> {
  UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name),
        status = $.text('status', (u) => u.status);

  final ColumnType<int?> id;

  final ColumnType<String> name;

  final ColumnType<String> status;

  @override
  User fromRow(RowReader read) => User(
        id: read(id),
        name: read(name),
        status: read(status),
      );
}

// `testTable` tags the table with the ANSI-flavored `TestDialect`, for code
// that does not target one driver.
final UserSchema users = testTable('users', UserSchema.new);

Future<void> main() async {
  // A `TestDelegate` talks to no database. It records every statement.
  final delegate = TestDelegate();
  final repository = UserRepository(Raindrop(delegate));

  await repository.deactivate(userId: 1);
  final (:sql, :values) = delegate.statements.single;
  print('Executed: $sql with $values');

  // Results are canned: queue one and the next statement returns it.
  delegate.enqueue(
    const DatabaseResult(
      columns: ['id', 'name', 'status'],
      rows: [
        [1, 'Alex', 'active'],
        [2, 'Sam', 'active'],
      ],
      rowsAffected: 0,
      lastInsertedRowId: null,
    ),
  );
  print('Active users: ${await repository.active()}');
}
