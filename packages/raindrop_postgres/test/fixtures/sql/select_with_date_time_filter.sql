SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "deletedAt" = $1

-- $1 = "2026-01-01 00:00:00.000Z"
