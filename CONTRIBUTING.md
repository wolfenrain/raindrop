# Contribution Guidelines

**Note:** If these contribution guidelines are not followed your issue or PR
might be closed, so please read these instructions carefully.

## Contribution types

### Bug Reports

- If you find a bug, please first report it using [GitHub issues].
  - First check if there is not already an issue for it, duplicated issues will
    be closed.

### Bug Fix

- If you'd like to submit a fix for a bug, please read the
  [How To](#how-to-contribute) for how to send a Pull Request.
- Indicate on the open issue that you are working on fixing the bug and the
  issue will be assigned to you.
- Write `Fixes #xxxx` in your PR text, where xxxx is the issue number (if there
  is one).
- Include a test that isolates the bug and verifies that it was fixed.

### New Features

- If you'd like to add a feature to the library that doesn't already exist, feel
  free to describe the feature in a new [GitHub issue].
- If you'd like to implement the new feature, please wait for feedback from the
  project maintainers before spending too much time writing the code. In some
  cases, enhancements may not align well with the project future development
  direction.
- Implement the code for the new feature and please read the
  [How To](#how-to-contribute).

### New Drivers

- raindrop is designed for third-party database drivers. A driver package
  provides a `SqlDialect`, a `RaindropDelegate`, column-type extensions on
  `SchemaBuilder`, and a `DdlGenerator` served from a main method in its
  `lib/ddl.dart` for migrations. The package's main library
  (`package:<name>/<name>.dart`) must export a `dialect` constant holding its
  `SqlDialect`.
- To verify a driver behaves the way raindrop expects, run the suites from
  [`raindrop_test`](https://pub.dev/packages/raindrop_test): implement
  `DriverTestHarness` and hand it to `testDriverConformance`.

### Documentation & Miscellaneous

- If you have suggestions for improvements to the documentation or examples (or
  something else), we would love to hear about it.
- As always first file a [GitHub issue].
- Implement the changes to the documentation, please read the
  [How To](#how-to-contribute).

## How To Contribute

### Requirements

For a contribution to be accepted:

- Format the code using `dart format .`;
- Lint the code with `dart analyze`;
- Check that all tests pass: `dart run melos run test`;
- Documentation should always be updated or added (if applicable);
- Examples should always be updated or added (if applicable);
- Tests should always be updated or added (if applicable);
- The PR title should start with a [conventional commit] prefix (`feat:`, `fix:`
  etc).

If the contribution doesn't meet these criteria, a maintainer will discuss it
with you on the issue or PR. You can still continue to add more commits to the
branch you have sent the Pull Request from and it will be automatically
reflected in the PR.

## Open an issue and fork the repository

- If it is a bigger change or a new feature, first of all
  [file a bug or feature report][GitHub issue], so that we can discuss what
  direction to follow.
- [Fork the project][fork guide] on GitHub.
- Clone the forked repository to your local development machine (e.g.
  `git clone git@github.com:<YOUR_GITHUB_USER>/raindrop.git`).

### Environment Setup

The packages live in a single [pub workspace], so a single `pub get` at the
repository root resolves every package against the local sources:

```shell
dart pub get
```

Repository-wide tasks are run through [melos] scripts:

```shell
dart run melos run analyze           # analyze every package
dart run melos run format            # verify formatting
dart run melos run format:fix        # apply formatting
dart run melos run test              # unit + integration tests for every package
dart run melos run test:unit         # unit tests only
dart run melos run test:integration  # integration tests only
```

The `raindrop_postgres` integration tests expect a Postgres instance on the
default port `5432` with the default `postgres`/`postgres` credentials, which
you can start with Docker:

```shell
docker run -d --rm --name raindrop-pg-test \
  -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:16-alpine
```

When your Postgres runs elsewhere, override any part of the endpoint through
the `RAINDROP_PG_HOST`, `RAINDROP_PG_PORT`, `RAINDROP_PG_DATABASE`,
`RAINDROP_PG_USER` and `RAINDROP_PG_PASSWORD` environment variables.

### Configuring CI for a package

Every package has a `ci.yaml` in its root that declares where and against what
its tests run, for example:

```yaml
os: [ubuntu-latest, windows-latest]
databases: [postgres:16, postgres:latest~]
```

- `os` lists the [runner labels] the package is tested on, and is required.
- `databases` lists the databases the tests need, one job per version of the
  same database. Versions are required (`postgres:16`), with two special values:
  `latest` resolves to the newest release, and `sqlite:bundled` is the library
  that `package:sqlite3` ships.
- A trailing `~` marks an entry as unstable: jobs using it are allowed to fail
  without failing CI. Moving targets like `latest` should always carry it.

The databases themselves are set up by the actions in `.github/actions`, one per
database, which is also where support for a new database gets added.

### Performing changes

- Create a new local branch from `main` (e.g. `git checkout -b my-new-feature`)
- Make your changes (try to split them up with one PR per feature/fix).
- When committing your changes, make sure that each commit message is clear
  (e.g. `git commit -m 'feat: add support for lateral joins'`).
- Push your new branch to your own fork into the same remote branch (e.g.
  `git push origin my-username.my-new-feature`, replace `origin` if you use
  another remote.)

### Breaking changes

When doing breaking changes a deprecation tag should be added when possible and
contain a message that conveys to the user which version the deprecated
method/field will be removed in and what method they should use instead to
perform the task. The version specified should be at least two versions after
the current one, such that there will be at least one stable release where the
users get to see the deprecation warning and in the version after that (or a
later version) the deprecated entity should be removed.

Example (if the current version is v1.3.0):

```dart
@Deprecated('Will be removed in v1.5.0, use nonDeprecatedFeature() instead')
void deprecatedFeature() {}
```

### Open a pull request

Go to the [pull request page of raindrop][PRs] and in the top of the page it
will ask you if you want to open a pull request from your newly created branch.

The title of the pull request should start with a [conventional commit] type.

Allowed types are:

- `fix:` -- patches a bug and is not a new feature;
- `feat:` -- introduces a new feature;
- `docs:` -- updates or adds documentation or examples;
- `test:` -- updates or adds tests;
- `refactor:` -- refactors code but doesn't introduce any changes or additions
  to the public API;
- `perf:` -- code change that improves performance;
- `build:` -- code change that affects the build system or external
  dependencies;
- `ci:` -- changes to the CI configuration files and scripts;
- `chore:` -- other changes that don't modify source or test files;
- `revert:` -- reverts a previous commit.

If you introduce a **breaking change** the conventional commit type MUST end
with an exclamation mark (e.g. `feat!: rename the query builder entry points`).

Examples of PR titles:

- feat: add support for lateral joins
- fix: avoid double-quoting column names in ORDER BY
- docs: add an example for derived tables
- test: add coverage for ON CONFLICT builders
- refactor: simplify dialect resolution

[GitHub issue]: https://github.com/wolfenrain/raindrop/issues
[GitHub issues]: https://github.com/wolfenrain/raindrop/issues
[PRs]: https://github.com/wolfenrain/raindrop/pulls
[fork guide]: https://docs.github.com/en/get-started/quickstart/contributing-to-projects
[pub workspace]: https://dart.dev/tools/pub/workspaces
[melos]: https://melos.invertase.dev
[conventional commit]: https://www.conventionalcommits.org
[runner labels]: https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources
