UPDATE "users" SET "name" = $1 WHERE "id" IN (SELECT "id" FROM "users" LIMIT 5)

-- $1 = "Renamed"
