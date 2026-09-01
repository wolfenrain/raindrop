<h1 align="center">💧 raindrop_sqlite</h1>

<p align="center">
<a href="https://pub.dev/packages/raindrop_sqlite"><img src="https://img.shields.io/pub/v/raindrop_sqlite.svg" alt="Pub"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://github.com/wolfenrain/raindrop/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://raw.githubusercontent.com/wolfenrain/raindrop/main/coverage.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

The SQLite driver for [`raindrop`](https://pub.dev/packages/raindrop), built on
[`sqlite3`](https://pub.dev/packages/sqlite3).

## Usage

Declare tables with `sqliteTable`, then hand a `SQLiteDelegate` to `Raindrop`:

```dart
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:sqlite3/sqlite3.dart';

final users = sqliteTable('users', UserSchema.new);

void main() async {
  final db = Raindrop(SQLiteDelegate(sqlite3.openInMemory()));

  final [user] = await db.insert(into: users).values([
    const User(name: 'Alex'),
  ]).returning();
}
```

SQLite ships with foreign key enforcement off, so the delegate turns it on for
its connection. Pass `enforceForeignKeys: false` to keep your own setting.

## Beyond the core DSL

Everything in the core [`raindrop`](https://pub.dev/packages/raindrop) DSL works
unchanged. On top of it this driver adds upserts:

```dart
await db.insert(into: users).values([user])
    .onConflict([users.email])
    .doUpdate([users.age.to(excluded(users.age))]);
// INSERT ... ON CONFLICT ("email") DO UPDATE SET "age" = "excluded"."age"
```

- `insertOrIgnore` renders `INSERT OR IGNORE`, skipping conflicting rows.
- `returning()` on inserts, updates and deletes yields the affected rows.
- `.limit(n)` caps updates and deletes. The driver probes the library for
  `SQLITE_ENABLE_UPDATE_DELETE_LIMIT` and falls back to a key-based rewrite.
- `unixepoch()` and `currentTimestamp()` evaluate in the database.
- Column types beyond the core set: `boolean`, `dateTime` (milliseconds since
  the epoch), `bigInt` and `blob`.
