import 'package:raindrop/raindrop.dart';
import 'package:test/test.dart';

class _TestDialect extends SqlDialect {
  const _TestDialect();

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
    return 'SELECT';
  }

  @override
  String translateUpdate<S extends Schema<S>, V>(
    Update<S, V> update,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    return 'UPDATE';
  }

  @override
  String translateDelete<S extends Schema<S>, V>(
    Delete<S, V> delete,
    List<Object?> values,
    AliasRegistry<S, V> registry,
  ) {
    return 'DELETE';
  }

  @override
  String translateFilter(
    Filter filter,
    List<Object?> values,
    AliasRegistry registry, [
    int level = 0,
  ]) {
    return 'FILTER';
  }
}

class Test extends Schema<Test> {
  Test({
    required String field,
  }) : field = _builder.text('field', (s) => s.field, value: field);

  final TextColumn field;

  static const _builder = SchemaBuilder<Test>();
}

final tests = table('tests', () => Test(field: 'field'));

class _UnknownQuery<S extends Schema<S>> extends Query<S, S> {
  const _UnknownQuery(this.table);

  final Table<S> table;
}

void main() {
  Raindrop.tracer.isTracing = true;

  group('$SqlDialect', () {
    late SqlDialect dialect;
    late Table<Test> table;

    setUp(() {
      dialect = _TestDialect();

      table = Table.getForSchema<Test>()!;
    });

    group('can translate', () {
      test('insert query', () {
        final insert = Insert<Test, void>(
          into: table,
          values: [Test(field: 'field')],
        );

        expect(
          dialect.translate(insert, AliasRegistry(insert)).$1,
          equals('INSERT'),
        );
      });

      test('select query', () {
        final select = Select(selecting: table, from: table);

        expect(
          dialect.translate(select, AliasRegistry(select)).$1,
          equals('SELECT'),
        );
      });

      test('update query', () {
        final update = Update<Test, String>(
          set: tests.field.set('field'),
          table: table,
        );

        expect(
          dialect.translate(update, AliasRegistry(update)).$1,
          equals('UPDATE'),
        );
      });
    });

    test('can not translate unknown query', () {
      final unknown = _UnknownQuery(table);

      expect(
        () => dialect.translate(unknown, AliasRegistry(unknown)),
        throwsUnsupportedError,
      );
    });
  });
}
