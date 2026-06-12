SELECT COALESCE("users"."name", $1), "users"."id" AS "users__id" FROM "users" INNER JOIN "pets" ON "users"."id" = "pets"."owner_id"

-- $1 = "anon"
