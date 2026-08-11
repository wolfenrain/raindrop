import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  final db = Raindrop(_RenderDelegate());

  group('now', () {
    test('renders the now() function call', () {
      expect(
        db.select(now()).from(_events).toString(),
        'SELECT now() FROM "events"',
      );
    });

    test('the expression class itself builds the same call', () {
      expect(
        db.select(Now()).from(_events).toString(),
        'SELECT now() FROM "events"',
      );
    });
  });

  group('genRandomUuid', () {
    test('renders the gen_random_uuid() function call', () {
      expect(
        db.select(genRandomUuid()).from(_events).toString(),
        'SELECT gen_random_uuid() FROM "events"',
      );
    });

    test('the expression class itself builds the same call', () {
      expect(
        db.select(GenRandomUuid()).from(_events).toString(),
        'SELECT gen_random_uuid() FROM "events"',
      );
    });
  });
}

class _Event {
  _Event({required this.name, this.id});

  final int? id;
  final String name;
}

class _EventSchema extends Schema<_Event> {
  _EventSchema(super.$)
      : id = $.integer('id', (e) => e.id).primaryKey(autoIncrement: true),
        name = $.text('name', (e) => e.name);

  final ColumnType<int?> id;
  final ColumnType<String> name;

  @override
  _Event fromRow(RowReader read) => _Event(id: read(id), name: read(name)!);
}

final _EventSchema _events = postgresTable('events', _EventSchema.new);

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
