SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "age" IN ("age", $1)

-- $1 = 30
