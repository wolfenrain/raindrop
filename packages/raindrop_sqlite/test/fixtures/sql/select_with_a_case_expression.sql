SELECT CASE WHEN "age" > $1 THEN $2 WHEN "age" > $3 THEN $4 ELSE $5 END FROM "users"

-- $1 = 65
-- $2 = "senior"
-- $3 = 17
-- $4 = "adult"
-- $5 = "minor"
