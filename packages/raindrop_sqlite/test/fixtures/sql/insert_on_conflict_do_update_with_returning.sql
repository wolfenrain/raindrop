INSERT INTO "users" ("name", "favoriteGame", "age", "is_active", "rating", "deletedAt") VALUES ($1, $2, $3, $4, $5, $6) ON CONFLICT ("name") DO UPDATE SET "age" = $7 RETURNING "id", "name", "favoriteGame", "age", "is_active", "rating", "deletedAt"

-- $1 = "Morgan"
-- $2 = "zelda"
-- $3 = 30
-- $4 = 1
-- $5 = 0.0
-- $6 = null
-- $7 = 31
