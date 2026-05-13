UPDATE "users" SET "name" = $1 WHERE "id" = $2 RETURNING "name"

-- $1 = "Renamed"
-- $2 = 1
