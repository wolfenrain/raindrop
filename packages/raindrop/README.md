<h1 align="center">💧 raindrop</h1>

<p align="center">
<a href="https://pub.dev/packages/raindrop"><img src="https://img.shields.io/pub/v/raindrop.svg" alt="Pub"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://github.com/wolfenrain/raindrop/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://raw.githubusercontent.com/wolfenrain/raindrop/main/coverage.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

A type-safe SQL toolkit for Dart that requires **no code generation**. Your
schema is ordinary Dart, your queries are checked by the compiler, and there is
no build step to run or keep in sync.

## Drivers

`raindrop` is the core package but does not talk to database itself, that is the
job of a driver:

| Package                                                           | Database | Maintained by |
| ----------------------------------------------------------------- | -------- | ------------- |
| [`raindrop_sqlite`](https://pub.dev/packages/raindrop_sqlite)     | SQLite   | raindrop      |
| [`raindrop_postgres`](https://pub.dev/packages/raindrop_postgres) | Postgres | raindrop      |

Community drivers are welcome: the
[driver guide](https://github.com/wolfenrain/raindrop/blob/main/CONTRIBUTING.md#new-drivers)
describes the contract and the test suites that verify it. Any driver that
passes that will be listed here.

## Getting started

Add the core and a driver, then hand `Raindrop` your driver's delegate:

```dart
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';

final db = Raindrop(SQLiteDelegate(sqlite3.openInMemory()));
```

Each driver's README shows its own connection setup.

## Defining a schema

A schema is a class describing how a row maps to your own type. Column handles
are fields, so the compiler knows every type.

```dart
class User {
  const User({required this.name, this.id});

  final int? id;

  final String name;
}

class UserSchema extends Schema<User> {
  UserSchema(super.$)
      : id = $.integer('id', (u) => u.id).primaryKey(autoIncrement: true),
        name = $.text('name', (u) => u.name);

  final ColumnType<int?> id;

  final ColumnType<String> name;

  @override
  User fromRow(RowReader read) => User(id: read(id), name: read(name)!);
}

final users = sqliteTable('users', UserSchema.new);
```

## Querying

The result type follows the projection: select two columns and you get a record
of two, select nothing and you get your row type back.

```dart
// List<User>, returns the whole row.
await db.select().from(users).where(users.name.equals('Alex'));

// List<(String, int)>, returns the record shape that came from the projection
await db
    .select(users.name, count(pets.id))
    .from(users)
    .join(pets, on: users.id.equals(pets.ownerId))
    .groupBy(users.id)
    .having(count(pets.id).greaterThan(1))
    .orderBy({users.name: Order.asc});
```

Subqueries, derived tables, `EXISTS`, `DISTINCT` and aggregates are all typed
the same way:

```dart
db.select(users.name).from(users).where(
      exists(db.select().from(pets).where(users.id.equals(pets.ownerId))),
    );

db.select.distinct(users.country, users.city).from(users);
```

`CASE` expressions read in SQL order, and stay nullable until an `orElse`
closes them:

```dart
// Expression<String>, every branch yields the same type.
caseWhen(users.age.greaterThan(65), then: 'senior')
    .when(users.age.greaterThan(17), then: 'adult')
    .orElse('minor');

// Expression<String?>: without an ELSE, an unmatched row is NULL.
caseWhen(users.nickname.isNotNull(), then: users.nickname);
```

When the DSL has no spelling for something, `raw()` is the escape hatch and
`raw.parts` keeps column handles and bound values intact rather than
interpolating them into text:

```dart
// No DSL spelling for window functions:
db
    .select(raw<int>('ROW_NUMBER() OVER (ORDER BY "age")'))
    .from(users);

// raw.parts keeps handles and bound values intact inside the fragment:
db.select().from(users).where(raw.parts([users.name, 'ILIKE', bind(pattern)]));
// WHERE "name" ILIKE $1
```

## Writing data

Inserts, updates and deletes use the same typed handles, and `returning()` gives
you the affected rows back as your own types (assuming your driver supports it):

```dart
final stored = await db.insert(into: users).values([
  User(name: 'Alex'),
]).returning();

await db
    .update(users)
    .set(users.name.to('Robin'))
    .where(users.id.equals(stored.single.id!));

await db.delete(from: users).where(users.name.equals('Robin'));
```

Transactions are also supported:

```dart
await db.transaction((tx) async {
  final owners = await tx.insert(into: users).values([
    User(name: 'Sam'),
  ]).returning();
  await tx.insert(into: pets).values([
    Pet(name: 'Rex', ownerId: owners.single.id!),
  ]);
});
```

## Migrations

Schemas are diffed into plain SQL migrations by
[`raindrop_cli`](https://pub.dev/packages/raindrop_cli), ship those with your
app and apply any that are still pending at startup:

```dart
await migrate(db, migrations);
```
