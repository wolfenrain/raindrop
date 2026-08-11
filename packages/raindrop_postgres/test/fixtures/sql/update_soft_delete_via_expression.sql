UPDATE "users" SET "deletedAt" = now() WHERE "id" = $1

-- $1 = 1
