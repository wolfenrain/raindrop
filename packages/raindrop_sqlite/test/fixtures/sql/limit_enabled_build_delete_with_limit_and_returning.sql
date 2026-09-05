DELETE FROM "users" WHERE "age" > $1 RETURNING "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" LIMIT 10

-- $1 = 0
