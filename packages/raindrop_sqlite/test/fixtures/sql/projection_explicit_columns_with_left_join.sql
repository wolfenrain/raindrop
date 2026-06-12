SELECT "users"."name" AS "users__name", "pets"."name" AS "pets__name" FROM "users" LEFT JOIN "pets" ON "users"."id" = "pets"."owner_id"
