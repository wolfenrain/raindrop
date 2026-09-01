<h1 align="center">💧 raindrop_postgres</h1>

<p align="center">
<a href="https://pub.dev/packages/raindrop_postgres"><img src="https://img.shields.io/pub/v/raindrop_postgres.svg" alt="Pub"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://github.com/wolfenrain/raindrop/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://raw.githubusercontent.com/wolfenrain/raindrop/main/coverage.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

The Postgres driver for [`raindrop`](https://pub.dev/packages/raindrop), built
on [`postgres`](https://pub.dev/packages/postgres).

## Usage

Declare tables with `postgresTable`, then hand a `PostgresDelegate` an open
`Connection` (or a `Pool`):

```dart
import 'package:postgres/postgres.dart';
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';

final users = postgresTable('users', UserSchema.new);

void main() async {
  final connection = await Connection.open(
    Endpoint(host: 'localhost', database: 'postgres', username: 'postgres'),
  );
  final db = Raindrop(PostgresDelegate(connection));

  final [user] = await db.insert(into: users).values([
    const User(name: 'Alex'),
  ]).returning();
}
```

The connection is yours: the driver does not pool, retry, or reconnect.

## Beyond the core DSL

Everything in the core [`raindrop`](https://pub.dev/packages/raindrop) DSL works
unchanged. On top of it this driver adds upserts:

```dart
await db.insert(into: users).values([user])
    .onConflict([users.email])
    .doUpdate([users.age.to(excluded(users.age))]);
// INSERT ... ON CONFLICT ("email") DO UPDATE SET "age" = "excluded"."age"
```

- `returning()` on inserts, updates and deletes yields the affected rows.
- `now()` and `genRandomUuid()` evaluate in the database.
- Column types beyond the core set: `boolean`, `dateTime` (`TIMESTAMP`),
  `bigInt` (`NUMERIC`), `textArray` (`TEXT[]`) and `blob` (`BYTEA`).
- `%` works on `bigInt` columns, computed over `NUMERIC`.
