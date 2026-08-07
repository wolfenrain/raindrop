import 'package:raindrop/raindrop.dart';

/// {@template unixepoch}
/// SQLite `unixepoch()`, seconds since the epoch, evaluated by the database.
/// {@endtemplate}
class Unixepoch extends Expression<int> {
  /// {@macro unixepoch}
  const Unixepoch();

  @override
  SQL build() => SQL.function('unixepoch', const []);
}

/// {@macro unixepoch}
Unixepoch unixepoch() => const Unixepoch();

/// {@template current_timestamp}
/// SQLite `CURRENT_TIMESTAMP`, `YYYY-MM-DD HH:MM:SS` in UTC.
/// {@endtemplate}
class CurrentTimestamp extends Expression<String> {
  /// {@macro current_timestamp}
  const CurrentTimestamp();

  @override
  SQL build() => SQL([const RawSQL('CURRENT_TIMESTAMP')]);
}

/// {@macro current_timestamp}
CurrentTimestamp currentTimestamp() => const CurrentTimestamp();
