SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "name" = $1 OR "name" = $2

-- $1 = "Morgan"
-- $2 = "Alex"
