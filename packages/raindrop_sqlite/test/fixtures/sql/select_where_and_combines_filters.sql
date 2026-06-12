SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "favoriteGame" = $1 AND "name" = $2

-- $1 = "zelda"
-- $2 = "Morgan"
