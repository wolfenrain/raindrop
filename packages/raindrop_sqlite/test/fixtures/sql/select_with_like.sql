SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "name" LIKE $1

-- $1 = "%est%"
