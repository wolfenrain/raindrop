UPDATE "users" SET "name" = $1 WHERE "age" > $2 LIMIT 5

-- $1 = "Renamed"
-- $2 = 18
