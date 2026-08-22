SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "age" BETWEEN $1 AND $2

-- $1 = 18
-- $2 = 65
