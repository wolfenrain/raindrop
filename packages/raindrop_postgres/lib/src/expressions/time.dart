import 'package:raindrop/raindrop.dart';

/// {@template now}
/// Postgres `now()`, the current transaction's timestamp.
/// {@endtemplate}
class Now extends Expression<DateTime> {
  /// {@macro now}
  const Now();

  @override
  SQL build() => SQL.function('now', const []);
}

/// {@macro now}
Now now() => const Now();

/// {@template gen_random_uuid}
/// Postgres `gen_random_uuid()`.
/// {@endtemplate}
class GenRandomUuid extends Expression<String> {
  /// {@macro gen_random_uuid}
  const GenRandomUuid();

  @override
  SQL build() => SQL.function('gen_random_uuid', const []);
}

/// {@macro gen_random_uuid}
GenRandomUuid genRandomUuid() => const GenRandomUuid();
