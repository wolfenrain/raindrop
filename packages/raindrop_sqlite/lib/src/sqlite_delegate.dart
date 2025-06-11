import 'package:sqlite3/sqlite3.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

/// {@template sqlite_delegate}
/// Delegate for the SQLite database.
/// {@endtemplate}
class SQLiteDelegate extends RaindropDelegate with _DatabaseDelegate {
  SQLiteDelegate._(this._database) : super(dialect: const SQLiteDialect());

  /// {@macro sqlite_delegate}
  ///
  /// Open the database at the [fileName].
  SQLiteDelegate.open(String fileName) : this._(sqlite3.open(fileName));

  @override
  final Database _database;

  @override
  Future<void> onOpen() async {}

  @override
  Future<void> onClose() async => _database.dispose();

  @override
  SQLiteInsertValuesBuilder<S, void> insert<S extends Schema<S>>(
    RaindropExecutor<Delegate> executor,
    Table<S> into,
  ) {
    return SQLiteInsertValuesBuilder(
      executor,
      config: QueryConfig.from({#into: into}),
    );
  }

  @override
  SQLiteUpdateSettingBuilder<S, void> update<S extends Schema<S>>(
    RaindropExecutor<Delegate> executor,
    Table<S> table,
  ) {
    return SQLiteUpdateSettingBuilder(
      executor,
      config: QueryConfig.from({#table: table}),
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) {
    throw UnimplementedError('transaction');
    // return _executor!.runTx((session) {
    //   return transaction(
    //     _TransactionDelegate._(session, dialect),
    //   );
    // });
  }
}

// class _TransactionDelegate extends TransactionDelegate with _DatabaseDelegate {
//   const _TransactionDelegate._(this._database, super.dialect);

//   @override
//   final Database _database;

//   @override
//   Future<void> rollback() => _database.rollback();
// }

mixin _DatabaseDelegate on Delegate {
  Database get _database;

  @override
  Future<List<Map<String, dynamic>>> execute(
    String query,
    List<Object?> values,
  ) {
    try {
      print(query);
      print(values);
      final result = _database.select(query, values);
      return Future.value(result.map((e) => {...e}).toList());
    } on SqliteException catch (err) {
      print(err);
      print(err.runtimeType);
      rethrow;
    }
  }
}
