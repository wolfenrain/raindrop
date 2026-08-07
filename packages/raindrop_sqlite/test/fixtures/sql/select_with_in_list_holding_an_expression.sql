SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "name" IN (COALESCE("favoriteGame", $1), $2)

-- $1 = "none"
-- $2 = "Morgan"
