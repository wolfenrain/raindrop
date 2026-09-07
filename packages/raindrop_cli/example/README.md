# raindrop_cli example

A package that keeps its schema in Dart and lets `raindrop_cli` write the SQL
migrations for it.

## Layout

```
my_app/
├── raindrop.yaml
├── lib/
│   ├── schemas/
│   │   └── users.dart
│   └── database/
│       └── migrations.dart      # generated
└── migrations/                  # generated
    ├── 0000_add_users.sql
    └── meta/
        ├── _journal.json
        └── 0000_snapshot.json
```

## Configuration

`raindrop.yaml`, next to `pubspec.yaml`:

```yaml
driver: raindrop_sqlite
schemas: lib/schemas
out: migrations
dart: lib/database/migrations.dart
```

`driver` names the driver package the schemas are written against. It must be
listed in `pubspec.yaml`, because the CLI introspects the schemas by running
them and loads the DDL generator from that package.

## A schema

`lib/schemas/users.dart`:

```dart
import 'package:raindrop/raindrop.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';

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
  User fromRow(RowReader read) => User(id: read(id), name: read(name));
}

final UserSchema users = sqliteTable('users', UserSchema.new, (table) {
  uniqueIndex('users_name').on(table.name);
});
```

## Generating a migration

```sh
dart pub global activate raindrop_cli
raindrop generate --name add_users
```

The CLI diffs the schemas against the last snapshot and writes
`migrations/0000_add_users.sql`:

```sql
CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "name" TEXT NOT NULL
);

CREATE UNIQUE INDEX "users_name" ON "users" ("name");
```

Because `dart:` is set, it also emits `lib/database/migrations.dart`, which
embeds every migration as a `Migration` for runtimes that cannot read files:

```dart
import 'package:raindrop/raindrop.dart';

/// Generated migrations. Do not edit by hand.
final migrations = [
  const Migration('0000_add_users', '''
CREATE TABLE "users" (
...'''),
];
```

Apply them at startup:

```dart
await migrate(db, migrations);
```

## Changing the schema

Add a column to `UserSchema`, then run `raindrop generate --name add_email`.
Only the difference becomes a migration:

```sql
ALTER TABLE "users" ADD COLUMN "email" TEXT;
```

`raindrop status` shows the configuration, the current schema and any pending
change without writing anything. `raindrop generate --empty --name
seeds`
creates a blank migration for hand-written SQL.
