UPDATE "users" SET "name" = COALESCE("name", $1) WHERE "id" = $2

-- $1 = "anon"
-- $2 = 1
