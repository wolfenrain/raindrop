SELECT "id", "name", "favoriteGame", "age", "deletedAt" FROM "users" WHERE "name" LIKE $1

-- $1 = "%est%"
