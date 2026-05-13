SELECT "id", "name", "favoriteGame", "age", "deletedAt" FROM "users" WHERE NOT ("name" = $1)

-- $1 = "Morgan"
