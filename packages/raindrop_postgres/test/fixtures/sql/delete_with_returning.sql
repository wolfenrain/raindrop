DELETE FROM "users" WHERE "id" = $1 RETURNING "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt"

-- $1 = 1
