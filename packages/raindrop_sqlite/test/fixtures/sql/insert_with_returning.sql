INSERT INTO "users" ("name", "favoriteGame", "age", "deletedAt") VALUES ($1, $2, $3, $4) RETURNING "id", "name", "favoriteGame", "age", "deletedAt"

-- $1 = "Morgan"
-- $2 = "zelda"
-- $3 = 30
-- $4 = null
