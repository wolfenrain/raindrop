SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "age" >= $1 AND "is_active" = $2 GROUP BY "favoriteGame" ORDER BY "age" DESC LIMIT 10 OFFSET 5

-- $1 = 18
-- $2 = 1
