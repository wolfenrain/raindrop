CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "deleted_at" TIMESTAMP
);

CREATE TABLE "pets" (
  "id" SERIAL PRIMARY KEY,
  "owner_id" INTEGER NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL
);