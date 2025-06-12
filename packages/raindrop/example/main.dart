// ignore_for_file: avoid_print

import 'package:raindrop/raindrop.dart';

// import 'posts.dart';
import 'users.dart';

void main() async {
  final db = Raindrop(FakeDelegate());

  final myUser = User(email: 'testing');
  await db.insert(into: users).values([myUser]);

  await db
      .update(users)
      .set(users.email.set('another'))
      .where(users.id.equals(1));

  final usersFound = await db.select().from(users).where(
        not(users.id.equals(1)) &
            (users.email.like('%@vdploeg.net') |
                users.email.like('%@wolfenra.in')),
      );

  print('users found: $usersFound');

  final specific = await db
      .select((users.email, users.id).$)
      .from(users)
      .where(not(users.id.equals(1)));

  print('specific found: $specific');

  // await db.transaction((tx) async {
  //   final [userFound] = await tx.query(SelectUser.byId(3));
  //   print('user with id 3: $userFound');
  // });

  await db.close();
}

// class SelectUser extends Select<User> {
//   SelectUser.byId(int id)
//       : super(selecting: users, from: users, where: users.id.equals(id));
// }

class FakeDialect extends SqlDialect {
  const FakeDialect();

  @override
  String translateFilter(
    Filter filter,
    List<Object?> values,
    AliasRegistry registry, [
    int level = 0,
  ]) {
    return 'FILTER';
  }

  @override
  String translateInsert<S extends Schema<S>, V>(
    Insert<S, V> insert,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    return 'INSERT';
  }

  @override
  String translateSelect<S extends Schema<S>, V>(
    Select<S, V> select,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    return 'SELECT $V';
  }

  @override
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    return 'UPDATE $V';
  }

  @override
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    return 'DELETE $V';
  }
}

class FakeDelegate extends RaindropDelegate {
  FakeDelegate() : super(dialect: const FakeDialect());

  @override
  Future<void> onOpen() async {}

  @override
  Future<void> onClose() async {}

  @override
  Future<List<Map<String, dynamic>>> execute(
    String query,
    List<Object?> values,
  ) async {
    return [
      {'id': 1, 'email': 'yes'},
    ];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate tx) transaction,
  ) {
    return transaction(FakeTransactionDelegate(dialect));
  }
}

class FakeTransactionDelegate extends TransactionDelegate {
  FakeTransactionDelegate(super.dialect);

  @override
  Future<List<Map<String, dynamic>>> execute(
    String query,
    List<Object?> values,
  ) async {
    print(query);
    return [];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) {
    return transaction(FakeTransactionDelegate(dialect));
  }

  @override
  Future<void> rollback() {
    throw UnimplementedError();
  }
}
