SELECT "id", "name", "favoriteGame", "age", "deletedAt" FROM "users" WHERE "name" = $1 OR "name" = $2

-- $1 = "Morgan"
-- $2 = "Alex"
