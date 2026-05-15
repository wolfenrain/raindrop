SELECT "users"."id" AS "users__id", "users"."name" AS "users__name", "users"."favoriteGame" AS "users__favoriteGame", "users"."age" AS "users__age", "users"."deletedAt" AS "users__deletedAt", "pets"."id" AS "pets__id", "pets"."owner_id" AS "pets__owner_id", "pets"."name" AS "pets__name" FROM "users" INNER JOIN "pets" ON "users"."id" = $1

-- $1 = -7
