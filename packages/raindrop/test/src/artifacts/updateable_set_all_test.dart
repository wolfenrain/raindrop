import 'dart:async';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:test/test.dart';

class _Row {
  _Row({this.id, required this.name, required this.notes});

  final int? id;
  final String name;
  final String notes;
}

class _RowSchema extends Schema<_Row> {
  _RowSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        name = $.text('name', (s) => s.name),
        notes = $.text('notes', (s) => s.notes);

  @override
  _Row fromRow(RowReader read) => _Row(
        id: read(id),
        name: read(name)!,
        notes: read(notes)!,
      );

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<String> notes;
}

void main() {
  final rows = sqliteTable('rows', _RowSchema.new);

  const dialect = SQLiteDialect();

  group('UpdateSettingBuilder.setAll', () {
    test('rejects an empty update list', () {
      final db = Raindrop(_FakeDelegate());
      expect(
        () => db.update(rows).setAll([]),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must not be empty'),
          ),
        ),
      );
    });

    test('setAll with one column matches set() SQL', () {
      final db = Raindrop(_FakeDelegate());
      final withSet =
          db.update(rows).set(rows.name.to('next')).where(rows.id.equals(1));
      final withSetAll = db
          .update(rows)
          .setAll([rows.name.to('next')]).where(rows.id.equals(1));

      final a = dialect.translate((withSet as ToQuery).compile());
      final b = dialect.translate((withSetAll as ToQuery).compile());
      expect(a.$1, b.$1);
      expect(a.$2, b.$2);
    });

    test('setAll accepts a built list and adds WHERE via where()', () {
      final db = Raindrop(_FakeDelegate());
      final updates = <Updateable<dynamic>>[
        rows.name.to('a'),
        rows.notes.to('b'),
      ];
      final q = db.update(rows).setAll(updates).where(rows.id.equals(42));

      final (sql, values) = dialect.translate((q as ToQuery).compile());
      expect(sql, contains('UPDATE'));
      expect(sql, contains('"name"'));
      expect(sql, contains('"notes"'));
      expect(sql, contains('WHERE'));
      expect(values, containsAll(<Object?>['a', 'b', 42]));
    });
  });
}

class _FakeTransactionDelegate extends TransactionDelegate {
  _FakeTransactionDelegate(super.dialect);

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) async {
    return const DatabaseResult(
      columns: [],
      rows: [],
      rowsAffected: 0,
      lastInsertedRowId: null,
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    return transaction(this);
  }

  @override
  Future<void> rollback() async {}
}

class _FakeDelegate extends RaindropDelegate {
  _FakeDelegate()
      : _tx = _FakeTransactionDelegate(const SQLiteDialect()),
        super(dialect: const SQLiteDialect());

  final _FakeTransactionDelegate _tx;

  @override
  Future<DatabaseResult> execute(String query, List<Object?> values) async {
    return const DatabaseResult(
      columns: [],
      rows: [],
      rowsAffected: 0,
      lastInsertedRowId: null,
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(TransactionDelegate delegate) transaction,
  ) async {
    return runZoned(
      () => transaction(_tx),
      zoneValues: {#delegate: _tx},
    );
  }
}
