INSERT INTO "pets" ("owner_id", "name") VALUES ($1, $2) RETURNING "id", "owner_id", "name"

-- $1 = 1
-- $2 = "Rex"
