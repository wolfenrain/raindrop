SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "name" = COALESCE("favoriteGame", $1)

-- $1 = "none"
