UPDATE "users" SET "name" = $1 WHERE "id" = $2 RETURNING "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt"

-- $1 = "Renamed"
-- $2 = 1
