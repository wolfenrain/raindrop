SELECT COALESCE("users"."name", $1), "users"."id" AS "users__id", "pets"."id" AS "pets__id", "pets"."owner_id" AS "pets__owner_id", "pets"."name" AS "pets__name" FROM "users" INNER JOIN "pets" ON "users"."id" = "pets"."owner_id"

-- $1 = "anon"
