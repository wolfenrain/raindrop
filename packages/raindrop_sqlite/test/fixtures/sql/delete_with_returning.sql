DELETE FROM "users" WHERE "id" = $1 RETURNING "id", "name", "favoriteGame", "age", "deletedAt"

-- $1 = 1
