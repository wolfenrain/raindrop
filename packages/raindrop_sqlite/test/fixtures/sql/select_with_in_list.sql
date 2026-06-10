SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "age" IN ($1, $2, $3)

-- $1 = 18
-- $2 = 21
-- $3 = 30
