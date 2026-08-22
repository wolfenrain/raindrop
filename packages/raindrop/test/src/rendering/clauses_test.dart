import 'package:raindrop/dialect.dart';
import 'package:raindrop_test/columns.dart';
import 'package:raindrop_test/raindrop_test.dart';
import 'package:test/test.dart';

void main() {
  final users = testTable('users', _UserSchema.new);
  final posts = testTable('posts', _PostSchema.new);
  final dialect = TestDialect();

  /// A hand-built statement standing in for a compiled `SELECT 1`.
  final selectOne = Query<int>(
    clauses: {1: Keyword('SELECT 1')},
    shape: SelectableResult<Object?>([]),
  );

  (String, List<Object?>) render(Clause clause) {
    final context = RenderContext(dialect);
    return (clause.render(context), context.values);
  }

  String sql(Clause clause) => render(clause).$1;

  group('ExpressionClause', () {
    test('''
a single-element list chunk holding a subquery loses the tuple parentheses''',
        () {
      final clause = ExpressionClause(
        SQL([
          [Subquery<int>(selectOne)],
        ]),
      );
      expect(sql(clause), '(SELECT 1)');
    });

    test('a column of an aliased table is qualified by the alias', () {
      final u = users.as('u');
      expect(sql(ExpressionClause(SQL([u.name]))), '"u"."name"');
    });

    test('an alias qualifies even when rendering single-table', () {
      final u = users.as('u');
      expect(
        sql(ExpressionClause(SQL([u.name]), singleTable: true)),
        '"u"."name"',
      );
    });

    test('a nested SQL chunk renders recursively', () {
      final inner = SQL([RawSQL('1 + 1')]);
      expect(sql(ExpressionClause(SQL([inner]))), '1 + 1');
    });

    test('a clause chunk renders through the clause itself', () {
      expect(sql(ExpressionClause(SQL([Keyword('NOW()')]))), 'NOW()');
    });
  });

  group('FilterClause', () {
    test('an unknown filter kind is rejected', () {
      final clause = FilterClause(_MysteryFilter());
      expect(
        () => sql(clause),
        throwsUnsupportedError,
      );
    });
  });

  group('SelectionClause', () {
    test('a schema selects all of its columns unqualified', () {
      expect(sql(SelectionClause(users)), '"id", "name", "age", "score"');
    });

    test('a table with joins present qualifies and aliases every column', () {
      expect(
        sql(SelectionClause(users.$, singleTable: false)),
        '''
"users"."id" AS "users__id", "users"."name" AS "users__name", "users"."age" AS "users__age", "users"."score" AS "users__score"''',
      );
    });

    test('an explicit column alias renders as AS', () {
      expect(sql(SelectionClause(users.name.as('n'))), '"name" AS "n"');
    });

    test('an explicit column alias survives qualification', () {
      expect(
        sql(SelectionClause(users.name.as('n'), singleTable: false)),
        '"users"."name" AS "n"',
      );
    });

    test('a column of an aliased table prefixes with the table alias', () {
      final u = users.as('u');
      expect(
        sql(SelectionClause(u.name, singleTable: false)),
        '"u"."name" AS "u__name"',
      );
    });

    test('an aliased expression renders with its output name', () {
      expect(
        sql(SelectionClause(length(users.name).as('len'))),
        'LENGTH("name") AS "len"',
      );
    });

    test('a bare expression renders without a name', () {
      expect(sql(SelectionClause(length(users.name))), 'LENGTH("name")');
    });

    test('a result renders each of its selections in order', () {
      final selection = SelectableResult<Object?>([
        users.name,
        length(users.name).as('len'),
      ]);
      expect(
        sql(SelectionClause(selection)),
        '"name", LENGTH("name") AS "len"',
      );
    });

    test('an unknown selectable renders nothing', () {
      expect(sql(SelectionClause(_MysterySelectable())), '');
    });
  });

  group('TableClause', () {
    test('renders the bare table name', () {
      expect(sql(TableClause(users.$)), '"users"');
    });

    test('renders an alias with AS', () {
      expect(sql(TableClause(users.as('u').$)), '"users" AS "u"');
    });

    test('a derived table renders its query parenthesized and aliased', () {
      final derived = users.$.asDerived(selectOne);
      expect(sql(TableClause(derived)), '(SELECT 1) AS "users"');
    });
  });

  group('HavingClause', () {
    test('prefixes the filter with HAVING', () {
      final clause = HavingClause(
        users.age.greaterThan(18),
        singleTable: true,
      );
      final (rendered, values) = render(clause);
      expect(rendered, r'HAVING "age" > $1');
      expect(values, [18]);
    });

    test('qualifies columns when not single-table', () {
      expect(
        sql(HavingClause(users.age.greaterThan(18))),
        r'HAVING "users"."age" > $1',
      );
    });
  });

  group('JoinsClause', () {
    final on = posts.authorId.equals(users.id);

    test('renders nothing for no joins', () {
      expect(sql(JoinsClause([])), '');
    });

    test('renders each join kind with its keyword', () {
      final expected = '"posts" ON "posts"."author_id" = "users"."id"';
      expect(
        sql(JoinsClause([InnerJoin(posts.$, on: on)])),
        'INNER JOIN $expected',
      );
      expect(
        sql(JoinsClause([LeftJoin(posts.$, on: on)])),
        'LEFT JOIN $expected',
      );
      expect(
        sql(JoinsClause([RightJoin(posts.$, on: on)])),
        'RIGHT JOIN $expected',
      );
    });

    test('renders multiple joins space-separated', () {
      final rendered = sql(
        JoinsClause([
          InnerJoin(posts.$, on: on),
          LeftJoin(posts.as('p').$, on: on),
        ]),
      );
      expect(rendered, contains('INNER JOIN "posts" ON'));
      expect(rendered, contains('LEFT JOIN "posts" AS "p" ON'));
    });

    test('an unknown join kind is rejected', () {
      expect(
        () => sql(JoinsClause([_MysteryJoin(posts.$, on: on)])),
        throwsUnsupportedError,
      );
    });
  });

  group('UpdateSetClause', () {
    test('a column assignment binds its value', () {
      final (rendered, values) = render(UpdateSetClause(users.name.to('bob')));
      expect(rendered, r'"name" = $1');
      expect(values, ['bob']);
    });

    test('a column can be assigned from another column', () {
      expect(sql(UpdateSetClause(users.age.to(users.age))), '"age" = "age"');
    });

    test('a whole-row assignment skips a null primary key', () {
      final clause = UpdateSetClause(
        UpdateableTable(users.$, _User(name: 'a', age: 2, score: 3)),
      );
      final (rendered, values) = render(clause);
      expect(rendered, r'"name" = $1, "age" = $2, "score" = $3');
      expect(values, ['a', 2, 3]);
    });

    test('a whole-row assignment keeps a present primary key', () {
      final clause = UpdateSetClause(
        UpdateableTable(users.$, _User(id: 7, name: 'a', age: 2, score: 3)),
      );
      final (rendered, values) = render(clause);
      expect(rendered, r'"id" = $1, "name" = $2, "age" = $3, "score" = $4');
      expect(values, [7, 'a', 2, 3]);
    });

    test('a result renders each assignment comma-separated', () {
      final clause = UpdateSetClause(
        UpdateableResult<Object?>([users.name.to('x'), users.age.to(1)]),
      );
      final (rendered, values) = render(clause);
      expect(rendered, r'"name" = $1, "age" = $2');
      expect(values, ['x', 1]);
    });

    test('an unknown updateable kind is rejected', () {
      expect(
        () => sql(UpdateSetClause(_MysteryUpdateable())),
        throwsUnsupportedError,
      );
    });
  });

  group('SetClause', () {
    test('prefixes the assignments with SET', () {
      expect(sql(SetClause(users.name.to('x'))), r'SET "name" = $1');
    });
  });

  group('GroupByClause', () {
    test('groups by a column', () {
      expect(sql(GroupByClause([users.name])), 'GROUP BY "name"');
    });

    test('groups by multiple terms, in order', () {
      expect(
        sql(GroupByClause([users.name, users.age])),
        'GROUP BY "name", "age"',
      );
    });

    test('qualifies the columns when not single-table', () {
      expect(
        sql(GroupByClause([users.name], singleTable: false)),
        'GROUP BY "users"."name"',
      );
    });

    test('groups by an expression', () {
      expect(
        sql(GroupByClause([length(users.name)])),
        'GROUP BY LENGTH("name")',
      );
    });

    test('an unsupported term is rejected', () {
      expect(() => sql(GroupByClause([users.$])), throwsUnsupportedError);
    });
  });

  group('OrderByClause', () {
    test('renders nothing for no terms', () {
      expect(sql(OrderByClause([])), '');
    });

    test('renders columns with their directions', () {
      final clause = OrderByClause([
        OrderBy(users.name, descending: false),
        OrderBy(users.age, descending: true),
      ]);
      expect(sql(clause), 'ORDER BY "name" ASC, "age" DESC');
    });

    test('renders an expression term', () {
      final clause = OrderByClause([
        OrderBy(length(users.name), descending: true),
      ]);
      expect(sql(clause), 'ORDER BY LENGTH("name") DESC');
    });

    test('qualifies columns when not single-table', () {
      final clause = OrderByClause(
        [OrderBy(users.name, descending: false)],
        singleTable: false,
      );
      expect(sql(clause), 'ORDER BY "users"."name" ASC');
    });

    test('an unsupported term is rejected', () {
      final clause = OrderByClause([OrderBy(users.$, descending: false)]);
      expect(() => sql(clause), throwsUnsupportedError);
    });
  });

  group('LimitClause', () {
    test('renders the row limit', () {
      expect(sql(LimitClause(10)), 'LIMIT 10');
    });
  });

  group('OffsetClause', () {
    test('renders the row offset', () {
      expect(sql(OffsetClause(5)), 'OFFSET 5');
    });
  });

  group('InsertBodyClause', () {
    test('drops a valueless primary key and a valueless defaulted column', () {
      final clause = InsertBodyClause(users.$, [_User(name: 'a', age: 1)]);
      final (rendered, values) = render(clause);
      expect(rendered, r'INTO "users" ("name", "age") VALUES ($1, $2)');
      expect(values, ['a', 1]);
    });

    test('keeps the primary key and default once any row has a value', () {
      final clause = InsertBodyClause(users.$, [
        _User(name: 'a', age: 1),
        _User(id: 9, name: 'b', age: 2, score: 5),
      ]);
      final (rendered, values) = render(clause);
      expect(
        rendered,
        'INTO "users" ("id", "name", "age", "score") '
        r'VALUES ($1, $2, $3, $4), ($5, $6, $7, $8)',
      );
      expect(values, [null, 'a', 1, null, 9, 'b', 2, 5]);
    });
  });

  group('QueryClause', () {
    test('renders clauses in weight order and drops empty ones', () {
      final query = Query<Object?>(
        clauses: {
          3: OrderByClause([]),
          2: FromClause(users.$),
          1: Keyword('SELECT *'),
        },
        shape: SelectableResult<Object?>([]),
      );
      expect(sql(QueryClause(query)), 'SELECT * FROM "users"');
    });
  });

  group('FromClause', () {
    test('prefixes the table with FROM', () {
      expect(sql(FromClause(users.$)), 'FROM "users"');
    });
  });

  group('DeleteFromClause', () {
    test('renders DELETE FROM with the table', () {
      expect(sql(DeleteFromClause(users.$)), 'DELETE FROM "users"');
    });
  });
}

class _User {
  _User({required this.name, required this.age, this.id, this.score});

  final int? id;
  final String name;
  final int age;
  final int? score;
}

class _UserSchema extends Schema<_User> {
  _UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name),
        age = $.integer('age', (u) => u.age),
        score = $.integer('score', (u) => u.score, defaultValue: 10);

  final ColumnType<int?> id;
  final ColumnType<String> name;
  final ColumnType<int> age;
  final ColumnType<int?> score;

  @override
  _User fromRow(RowReader read) => _User(
        id: read(id),
        name: read(name),
        age: read(age),
        score: read(score),
      );
}

class _Post {
  _Post({required this.title, this.id, this.authorId});

  final int? id;
  final int? authorId;
  final String title;
}

class _PostSchema extends Schema<_Post> {
  _PostSchema(super.$)
      : id = $.integer('id', (p) => p.id).primaryKey(autoIncrement: true),
        authorId = $.integer('author_id', (p) => p.authorId),
        title = $.text('title', (p) => p.title);

  final ColumnType<int?> id;
  final ColumnType<int?> authorId;
  final ColumnType<String> title;

  @override
  _Post fromRow(RowReader read) => _Post(
        id: read(id),
        authorId: read(authorId),
        title: read(title),
      );
}

/// A filter kind the renderer does not know.
class _MysteryFilter extends Filter {
  _MysteryFilter();
}

/// A selectable kind the renderer does not know.
class _MysterySelectable implements Selectable<Object?> {}

/// An updateable kind the renderer does not know.
class _MysteryUpdateable implements Updateable<Object?> {}

/// A join kind the renderer does not know.
class _MysteryJoin extends Join<Schema<_Post>, _Post> {
  _MysteryJoin(super.table, {required super.on});
}
