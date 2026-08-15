UPDATE "users" SET "name" = $1 WHERE "age" > $2 RETURNING "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" LIMIT 5

-- $1 = "Renamed"
-- $2 = 18
