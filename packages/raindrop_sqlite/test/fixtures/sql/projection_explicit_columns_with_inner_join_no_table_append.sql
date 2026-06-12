SELECT "users"."id" AS "users__id", "users"."name" AS "users__name", "pets"."name" AS "pets__name" FROM "users" INNER JOIN "pets" ON "users"."id" = "pets"."owner_id"
