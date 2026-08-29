SELECT SUBSTR("name", $1, $2), REPLACE("favoriteGame", $3, $4), ("name" || $5 || "favoriteGame") FROM "users"

-- $1 = 1
-- $2 = 3
-- $3 = "zel"
-- $4 = "ZEL"
-- $5 = " likes "
