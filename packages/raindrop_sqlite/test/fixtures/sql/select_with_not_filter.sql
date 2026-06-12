SELECT "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt" FROM "users" WHERE NOT ("name" = $1)

-- $1 = "Morgan"
