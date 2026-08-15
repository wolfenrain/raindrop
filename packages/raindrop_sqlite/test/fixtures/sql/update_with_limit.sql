UPDATE "users" SET "name" = $1 WHERE "id" IN (SELECT "id" FROM "users" WHERE "age" > $2 LIMIT 5)

-- $1 = "Renamed"
-- $2 = 18
