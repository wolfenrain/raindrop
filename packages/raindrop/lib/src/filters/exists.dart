import 'package:raindrop/raindrop.dart';

/// `EXISTS (SELECT ...)`, true when [query] matches any row.
///
/// ```dart
/// db.select(users.name).from(users).where(
///       exists(db.select().from(pets).where(users.id.equals(pets.ownerId))),
///     );
/// // WHERE EXISTS (SELECT ... FROM "pets" WHERE "users"."id" = "pets"."ownerId")
/// ```
///
/// For `NOT EXISTS` wrap it with [not]: `not(exists(query))`.
SQL exists(ToQuery<dynamic, dynamic> query) =>
    SQL([const RawSQL('EXISTS'), subquery(query)]);
