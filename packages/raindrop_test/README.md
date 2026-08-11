<h1 align="center">💧 raindrop_test</h1>

<p align="center">
<a href="https://pub.dev/packages/raindrop_test"><img src="https://img.shields.io/pub/v/raindrop_test.svg" alt="Pub"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://github.com/wolfenrain/raindrop/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://raw.githubusercontent.com/wolfenrain/raindrop/main/coverage.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

Testing utilities for [`raindrop`](https://pub.dev/packages/raindrop), including
golden SQL tests and a fake database delegate.

```yaml
dev_dependencies:
  raindrop_test: any
```

## Golden SQL tests

A `GoldenTester` compares the SQL a query builder generates against a fixture
file, without touching a database. Fixture paths are derived from the group and
test names:

```dart
import 'package:raindrop_test/raindrop_test.dart';

void main() {
  final golden = GoldenTester(dialect: SQLiteDialect());

  group('select', () {
    golden.test('with limit', (db) {
      return db.select(users.name).from(users).limit(1);
    });
    // Compared against test/fixtures/sql/select_with_limit.sql
  });
}
```

A missing fixture is written on first run and the test fails, so a fresh golden
is always inspected before it starts passing. After an intentional change,
regenerate with:

```sh
UPDATE_GOLDENS=1 dart test
```

Any `SqlDialect` works, `TestDialect` is an ANSI-flavored one for suites that do
not target a specific driver.

## TestDelegate

A `RaindropDelegate` that talks to no database. It records every statement, so
code that issues queries can be tested without one:

```dart
final delegate = TestDelegate();
final db = Raindrop(delegate);

await repository(db).deactivate(userId: 1);

expect(delegate.statements.last.sql, 'UPDATE "users" SET "is_active" = \$1 WHERE "id" = \$2');
```

Results are canned: return them per statement with `onExecute`, or queue them
FIFO with `enqueue`:

```dart
final delegate = TestDelegate()
  ..enqueue(
    DatabaseResult(
      columns: ['id', 'owner_id', 'name'],
      rows: [
        [1, 7, 'Rex'],
      ],
      rowsAffected: 0,
      lastInsertedRowId: null,
    ),
  );

final pets = await Raindrop(delegate).select().from(petsTable);
```

Transactions work too, the body runs against a nested delegate sharing the same
log, with `BEGIN`/`COMMIT`/`ROLLBACK` and savepoints recorded as statements.

## Driver conformance

`package:raindrop_test/conformance.dart` ships the behavioral suite every
raindrop driver must pass like CRUD round-trips, filters, joins, aggregates and
transaction semantics and it runs against a real database. The fixture tables
are created through your driver's own `DdlGenerator`, so DDL generation is part
of the contract. Implement a harness and hand it to the suite:

```dart
import 'package:raindrop_test/conformance.dart';

class MyDriverHarness extends DriverTestHarness {
  @override
  Future<RaindropDelegate> open() async => /* connect to the database */;

  @override
  DdlGenerator createDdlGenerator() => MyDriverDdlGenerator();

  @override
  Future<void> close(RaindropDelegate delegate) async => /* dispose */;
}

void main() {
  testDriverConformance(MyDriverHarness());
}
```

If your database can make writes yield rows (`RETURNING`, `OUTPUT`, ...),
declare the capability by passing your driver's own transforms, the suite then
covers those too:

```dart
testDriverConformance(
  MyDriverHarness(),
  returning: ReturningSupport(
    insert: (builder) => builder.returning(),
    update: (builder) => builder.returning(),
    delete: (builder) => builder.returning(),
  ),
);
```

Override `isAvailable()` to probe for a server so the suite skips instead of
failing where the database cannot run (the SQLite and Postgres drivers show both
styles).
