SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE "age" > ("age" + $1)

-- $1 = 1
