<h1 align="center">💧 raindrop_cli</h1>

<p align="center">
<a href="https://pub.dev/packages/raindrop_cli"><img src="https://img.shields.io/pub/v/raindrop_cli.svg" alt="Pub"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://github.com/wolfenrain/raindrop/actions/workflows/main.yaml/badge.svg" alt="ci"></a>
<a href="https://github.com/wolfenrain/raindrop/actions"><img src="https://raw.githubusercontent.com/wolfenrain/raindrop/main/coverage.svg" alt="coverage"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

The command line tool for [`raindrop`](https://pub.dev/packages/raindrop). It
generates SQL migrations by diffing your Dart schema against the last snapshot.

```sh
dart pub global activate raindrop_cli
```

## Configuration

A `raindrop.yaml` next to your package:

```yaml
# Required: the driver package to introspect and generate with.
driver: raindrop_sqlite

# Where your schema files live.
schemas: lib/schemas

# Where .sql migrations are written (default: migrations/).
out: migrations

# Optional: also emit the migrations as Dart source. Needed for runtimes that
# cannot read files at runtime.
dart: lib/database/migrations.dart

# Optional: "integer" (0000_, 0001_, ...) or "timestamp".
migration_naming: integer
```

## Commands

```sh
raindrop generate --name add_users   # diff the schema, write the migration
raindrop generate --dry-run -n x     # show the SQL, write nothing
raindrop generate --empty -n seeds   # a hand-written migration
raindrop generate --dart-only        # re-emit the embedded Dart from the journal
raindrop status                      # config, current schema, pending changes
```
