DELETE FROM "users" WHERE "id" IN (SELECT "id" FROM "users" WHERE "age" > $1 LIMIT 10)

-- $1 = 0
